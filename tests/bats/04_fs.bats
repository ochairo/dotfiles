#!/usr/bin/env bats
# Test suite for fs.sh - File system operations

# load "../test_helper"  # Not needed - using minimal setup

setup() {
    local dotfiles_root
    dotfiles_root="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    export DOTFILES_ROOT="$dotfiles_root/src"

    # CRITICAL SAFETY CHECK: Ensure we're in test mode
    if [ "$BATS_TEST_TMPDIR" = "" ] || [ "$BATS_TMPDIR" = "" ]; then
        echo "CRITICAL ERROR: Test isolation not working - BATS temp dirs not set!"
        return 1
    fi

    # Set up test environment in isolated temp directory
    export LEDGER_FILE="$BATS_TEST_TMPDIR/symlinks.log"
    export DOTFILES_BACKUP=0  # Default to no backup
    export DOTFILES_TRANSACTIONAL=0  # Default to non-transactional

    # Source bootstrap and dependencies
    source "$DOTFILES_ROOT/core/bootstrap.sh"
    core_require log
    source "$DOTFILES_ROOT/core/fs.sh"

    # Create test files and directories
    mkdir -p "$BATS_TEST_TMPDIR"/{source,target,backup}
    echo "source content" > "$BATS_TEST_TMPDIR/source/test.txt"
    echo "target content" > "$BATS_TEST_TMPDIR/target/existing.txt"

    # Create a test symlink
    ln -s "$BATS_TEST_TMPDIR/source/test.txt" "$BATS_TEST_TMPDIR/target/existing-link"
}

teardown() {
    # Clean up test environment
    unset DOTFILES_BACKUP DOTFILES_TRANSACTIONAL DOT_TXN_DIR
}

# =============================================================================
# BACKUP TESTS
# =============================================================================

@test "fs_backup_if_exists: backs up existing file" {
    local target="$BATS_TEST_TMPDIR/target/existing.txt"

    run fs_backup_if_exists "$target"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "Backup created:" ]]

    # Original file should be gone
    [ ! -f "$target" ]

    # Backup should exist with timestamp
    local backup_count
    backup_count=$(find "$BATS_TEST_TMPDIR/target" -name "existing.txt.bak.*" | wc -l)
    [ "$backup_count" -eq 1 ]

    # Backup should have original content
    local backup_file
    backup_file=$(find "$BATS_TEST_TMPDIR/target" -name "existing.txt.bak.*")
    [ "$(cat "$backup_file")" = "target content" ]
}

@test "fs_backup_if_exists: backs up existing symlink" {
    local target="$BATS_TEST_TMPDIR/target/existing-link"

    run fs_backup_if_exists "$target"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "Backup created:" ]]

    # Original symlink should be gone
    [ ! -L "$target" ]

    # Backup should exist
    local backup_count
    backup_count=$(find "$BATS_TEST_TMPDIR/target" -name "existing-link.bak.*" | wc -l)
    [ "$backup_count" -eq 1 ]
}

@test "fs_backup_if_exists: does nothing for non-existent file" {
    local target="$BATS_TEST_TMPDIR/target/nonexistent.txt"

    run fs_backup_if_exists "$target"

    [ "$status" -eq 0 ]
    [ "$output" = "" ]

    # No backup should be created
    local backup_count
    backup_count=$(find "$BATS_TEST_TMPDIR/target" -name "nonexistent.txt.bak.*" 2>/dev/null | wc -l)
    [ "$backup_count" -eq 0 ]
}

@test "fs_backup_if_exists: handles file with spaces in name" {
    local target="$BATS_TEST_TMPDIR/target/file with spaces.txt"
    echo "spaced content" > "$target"

    run fs_backup_if_exists "$target"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "Backup created:" ]]

    # Original file should be gone
    [ ! -f "$target" ]

    # Backup should exist
    local backup_count
    backup_count=$(find "$BATS_TEST_TMPDIR/target" -name "file with spaces.txt.bak.*" | wc -l)
    [ "$backup_count" -eq 1 ]
}

# =============================================================================
# REMOVE OR BACKUP TESTS
# =============================================================================

@test "fs_remove_or_backup: removes file when backup disabled" {
    export DOTFILES_BACKUP=0
    local target="$BATS_TEST_TMPDIR/target/existing.txt"

    run fs_remove_or_backup "$target"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "Removed" ]]

    # File should be gone
    [ ! -f "$target" ]

    # No backup should exist
    local backup_count
    backup_count=$(find "$BATS_TEST_TMPDIR/target" -name "existing.txt.bak.*" 2>/dev/null | wc -l)
    [ "$backup_count" -eq 0 ]
}

@test "fs_remove_or_backup: backs up file when backup enabled" {
    export DOTFILES_BACKUP=1
    local target="$BATS_TEST_TMPDIR/target/existing.txt"

    run fs_remove_or_backup "$target"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "Backup created:" ]]

    # Original file should be gone
    [ ! -f "$target" ]

    # Backup should exist
    local backup_count
    backup_count=$(find "$BATS_TEST_TMPDIR/target" -name "existing.txt.bak.*" | wc -l)
    [ "$backup_count" -eq 1 ]
}

@test "fs_remove_or_backup: handles directory removal" {
    local target="$BATS_TEST_TMPDIR/target/test-dir"
    mkdir -p "$target/subdir"
    echo "dir content" > "$target/file.txt"

    export DOTFILES_BACKUP=0
    run fs_remove_or_backup "$target"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "Removed" ]]

    # Directory should be gone
    [ ! -d "$target" ]
}

@test "fs_remove_or_backup: does nothing for non-existent file" {
    local target="$BATS_TEST_TMPDIR/target/nonexistent.txt"

    run fs_remove_or_backup "$target"

    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

# =============================================================================
# SYMLINK RECORD TESTS
# =============================================================================

@test "fs_symlink_record: creates ledger file with header" {
    local dest="$BATS_TEST_TMPDIR/target/link.txt"
    local src="$BATS_TEST_TMPDIR/source/test.txt"

    run fs_symlink_record "$dest" "$src" "test-component"

    [ "$status" -eq 0 ]
    [ -f "$LEDGER_FILE" ]

    # Check header
    local header
    header=$(head -1 "$LEDGER_FILE")
    [[ "$header" =~ "# ledgerv1" ]]
    [[ "$header" =~ "fields=dest,src,component" ]]
    [[ "$header" =~ "timestamp=" ]]

    # Check record
    local record
    record=$(tail -1 "$LEDGER_FILE")
    [[ "$record" =~ "$dest"$'\t'"$src"$'\t'"test-component" ]]
}

@test "fs_symlink_record: appends to existing ledger" {
    # Create initial ledger
    echo "# ledgerv1 fields=dest,src,component timestamp=2023-01-01T00:00:00Z" > "$LEDGER_FILE"
    echo -e "/old/dest\t/old/src\told-component" >> "$LEDGER_FILE"

    local dest="$BATS_TEST_TMPDIR/target/link.txt"
    local src="$BATS_TEST_TMPDIR/source/test.txt"

    run fs_symlink_record "$dest" "$src" "new-component"

    [ "$status" -eq 0 ]

    # Should have 3 lines total (header + 2 records)
    local line_count
    line_count=$(wc -l < "$LEDGER_FILE")
    [ "$line_count" -eq 3 ]

    # New record should be last
    local last_record
    last_record=$(tail -1 "$LEDGER_FILE")
    [[ "$last_record" =~ "$dest"$'\t'"$src"$'\t'"new-component" ]]

    # Old record should still be there
    [[ "$(cat "$LEDGER_FILE")" =~ "old-component" ]]
}

@test "fs_symlink_record: handles missing component parameter" {
    local dest="$BATS_TEST_TMPDIR/target/link.txt"
    local src="$BATS_TEST_TMPDIR/source/test.txt"

    run fs_symlink_record "$dest" "$src"

    [ "$status" -eq 0 ]
    [ -f "$LEDGER_FILE" ]

    # Record should have empty component field
    local record
    record=$(tail -1 "$LEDGER_FILE")
    [[ "$record" =~ "$dest"$'\t'"$src"$'\t'$ ]]
}

@test "fs_symlink_record: creates ledger directory" {
    export LEDGER_FILE="$BATS_TEST_TMPDIR/deep/nested/ledger.log"
    local dest="$BATS_TEST_TMPDIR/target/link.txt"
    local src="$BATS_TEST_TMPDIR/source/test.txt"

    run fs_symlink_record "$dest" "$src" "test-component"

    [ "$status" -eq 0 ]
    [ -f "$LEDGER_FILE" ]
    [ -d "$BATS_TEST_TMPDIR/deep/nested" ]
}

# =============================================================================
# SYMLINK CREATION TESTS
# =============================================================================

@test "fs_symlink: creates new symlink" {
    local src="$BATS_TEST_TMPDIR/source/test.txt"
    local dest="$BATS_TEST_TMPDIR/target/new-link.txt"

    run fs_symlink "$src" "$dest" "test-component"

    [ "$status" -eq 0 ]
    [[ "$output" =~ Linked.*$dest.*-\>.*$src ]]

    # Symlink should exist and point to source
    [ -L "$dest" ]
    [ "$(readlink "$dest")" = "$src" ]

    # Should be recorded in ledger
    [ -f "$LEDGER_FILE" ]
    [[ "$(cat "$LEDGER_FILE")" =~ "$dest"$'\t'"$src"$'\t'"test-component" ]]
}

@test "fs_symlink: skips existing correct symlink" {
    local src="$BATS_TEST_TMPDIR/source/test.txt"
    local dest="$BATS_TEST_TMPDIR/target/existing-link"

    # existing-link already points to source/test.txt
    run fs_symlink "$src" "$dest" "test-component"

    [ "$status" -eq 0 ]
    [[ "$output" =~ Symlink\ OK:.*$dest ]]

    # Symlink should still exist and be correct
    [ -L "$dest" ]
    [ "$(readlink "$dest")" = "$src" ]
}

@test "fs_symlink: replaces incorrect symlink" {
    local old_src="$BATS_TEST_TMPDIR/source/test.txt"
    local new_src="$BATS_TEST_TMPDIR/source/other.txt"
    local dest="$BATS_TEST_TMPDIR/target/changing-link"

    # Create test files
    echo "other content" > "$new_src"
    ln -s "$old_src" "$dest"

    run fs_symlink "$new_src" "$dest" "test-component"

    [ "$status" -eq 0 ]
    [[ "$output" =~ Linked.*$dest.*-\>.*$new_src ]]

    # Symlink should now point to new source
    [ -L "$dest" ]
    [ "$(readlink "$dest")" = "$new_src" ]
}

@test "fs_symlink: replaces existing file" {
    local src="$BATS_TEST_TMPDIR/source/test.txt"
    local dest="$BATS_TEST_TMPDIR/target/existing.txt"

    # existing.txt is a regular file
    export DOTFILES_BACKUP=0
    run fs_symlink "$src" "$dest" "test-component"

    [ "$status" -eq 0 ]
    [[ "$output" =~ Removed.*$dest ]]
    [[ "$output" =~ Linked.*$dest.*-\>.*$src ]]

    # Should now be a symlink
    [ -L "$dest" ]
    [ "$(readlink "$dest")" = "$src" ]
}

@test "fs_symlink: creates intermediate directories" {
    local src="$BATS_TEST_TMPDIR/source/test.txt"
    local dest="$BATS_TEST_TMPDIR/target/deep/nested/dirs/link.txt"

    run fs_symlink "$src" "$dest" "test-component"

    [ "$status" -eq 0 ]
    [[ "$output" =~ Linked.*$dest.*-\>.*$src ]]

    # All intermediate directories should exist
    [ -d "$BATS_TEST_TMPDIR/target/deep/nested/dirs" ]

    # Symlink should exist
    [ -L "$dest" ]
    [ "$(readlink "$dest")" = "$src" ]
}

@test "fs_symlink: handles relative paths" {
    local src="../source/test.txt"
    local dest="$BATS_TEST_TMPDIR/target/relative-link.txt"

    cd "$BATS_TEST_TMPDIR/target"
    run fs_symlink "$src" "$dest" "test-component"

    [ "$status" -eq 0 ]
    [ -L "$dest" ]
    [ "$(readlink "$dest")" = "$src" ]
}

# =============================================================================
# TRANSACTIONAL MODE TESTS
# =============================================================================

@test "fs_symlink: stages symlink in transactional mode" {
    export DOTFILES_TRANSACTIONAL=1
    export DOT_TXN_DIR="$BATS_TEST_TMPDIR/transaction"
    mkdir -p "$DOT_TXN_DIR"

    local src="$BATS_TEST_TMPDIR/source/test.txt"
    local dest="$BATS_TEST_TMPDIR/target/txn-link.txt"

    run fs_symlink "$src" "$dest" "test-component"

    [ "$status" -eq 0 ]

    # Symlink should NOT be created yet (staged only)
    [ ! -L "$dest" ]

    # Transaction directory should have staging info
    [ -d "$DOT_TXN_DIR" ]
}

# =============================================================================
# ERROR HANDLING TESTS
# =============================================================================

@test "fs_backup_if_exists: handles read-only files" {
    local target="$BATS_TEST_TMPDIR/target/readonly.txt"
    echo "readonly content" > "$target"
    chmod 444 "$target"

    run fs_backup_if_exists "$target"

    [ "$status" -eq 0 ]
    [[ "$output" =~ "Backup created:" ]]

    # Original should be gone
    [ ! -f "$target" ]

    # Backup should exist and be readable
    local backup_file
    backup_file=$(find "$BATS_TEST_TMPDIR/target" -name "readonly.txt.bak.*")
    [ -f "$backup_file" ]
    [ "$(cat "$backup_file")" = "readonly content" ]
}

# =============================================================================
# INTEGRATION TESTS
# =============================================================================

@test "integration: full symlink workflow with backup" {
    export DOTFILES_BACKUP=1
    local src="$BATS_TEST_TMPDIR/source/test.txt"
    local dest="$BATS_TEST_TMPDIR/target/existing.txt"

    # existing.txt contains "target content"

    run fs_symlink "$src" "$dest" "integration-test"

    [ "$status" -eq 0 ]

    # Should have created backup and new symlink
    [[ "$output" =~ "Backup created:" ]]
    [[ "$output" =~ Linked.*$dest.*-\>.*$src ]]

    # Backup should exist with original content
    local backup_file
    backup_file=$(find "$BATS_TEST_TMPDIR/target" -name "existing.txt.bak.*")
    [ -f "$backup_file" ]
    [ "$(cat "$backup_file")" = "target content" ]

    # New symlink should exist and point to source
    [ -L "$dest" ]
    [ "$(readlink "$dest")" = "$src" ]

    # Should be recorded in ledger
    [ -f "$LEDGER_FILE" ]
    [[ "$(cat "$LEDGER_FILE")" =~ "$dest"$'\t'"$src"$'\t'"integration-test" ]]
}

@test "stress: many symlinks in sequence" {
    local src="$BATS_TEST_TMPDIR/source/test.txt"

    # Create many symlinks
    for i in {1..20}; do
        local dest="$BATS_TEST_TMPDIR/target/stress-link-$i.txt"
        fs_symlink "$src" "$dest" "stress-test-$i"

        # Verify each symlink
        [ -L "$dest" ]
        [ "$(readlink "$dest")" = "$src" ]
    done

    # Verify all recorded in ledger
    [ -f "$LEDGER_FILE" ]
    local record_count
    record_count=$(grep -c "stress-test-" "$LEDGER_FILE")
    [ "$record_count" -eq 20 ]
}
