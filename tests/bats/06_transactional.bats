#!/usr/bin/env bats
# Test suite for transactional.sh - Transactional operations and state management
# shellcheck disable=SC2030,SC2031  # Variable modifications in BATS subshells are intentional for test isolation

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

    # Source required modules first (these will set STATE_DIR from constants.sh)
    # shellcheck disable=SC1091  # Path is set dynamically in test environment
    source "$DOTFILES_ROOT/core/fs/fs.sh"
    # shellcheck disable=SC1091  # Path is set dynamically in test environment
    source "$DOTFILES_ROOT/core/fs/transactional.sh"

    # THEN override with test directories (must be after sourcing)
    export STATE_DIR="$BATS_TEST_TMPDIR/state"
    export LEDGER_FILE="$STATE_DIR/symlinks.log"
    export COMPONENTS_DIR="$BATS_TEST_TMPDIR/components"  # For fs.sh compatibility
    mkdir -p "$STATE_DIR" "$COMPONENTS_DIR"

    # CRITICAL SAFETY CHECK: Never allow tests to use real components directory
    if [[ "$COMPONENTS_DIR" == *"/src/components"* ]]; then
        echo "FATAL ERROR: Test attempted to use real components directory!" >&2
        echo "COMPONENTS_DIR=$COMPONENTS_DIR" >&2
        exit 1
    fi

    # Set up test files and directories
    mkdir -p "$BATS_TEST_TMPDIR"/{source,target}
    echo "source content" > "$BATS_TEST_TMPDIR/source/test.txt"

    # Default to transactional mode for most tests
    export DOTFILES_TRANSACTIONAL=1

    # Suppress log output for cleaner test output
    export DOTFILES_LOG_LEVEL="ERROR"
}

teardown() {
    # Clean up test environment
    unset DOTFILES_TRANSACTIONAL DOT_TXN_DIR STATE_DIR LEDGER_FILE DOTFILES_LOG_LEVEL
}

# =============================================================================
# TRANSACTION BEGIN TESTS
# =============================================================================

@test "transaction_begin: creates transaction directory in transactional mode" {
    export DOTFILES_TRANSACTIONAL=1

    transaction_begin  # Don't use run here since we need DOT_TXN_DIR in this shell

    [ -n "${DOT_TXN_DIR:-}" ]
    [ -d "$DOT_TXN_DIR" ]
    [ -d "$DOT_TXN_DIR/stage" ]
    [ -f "$DOT_TXN_DIR/journal.log" ]
}

@test "transaction_begin: creates unique transaction directories" {
    export DOTFILES_TRANSACTIONAL=1

    # Start first transaction
    transaction_begin
    local first_txn_dir="$DOT_TXN_DIR"

    # Wait a moment to ensure different timestamp
    sleep 1

    # Start second transaction (should reset DOT_TXN_DIR)
    transaction_begin
    local second_txn_dir="$DOT_TXN_DIR"

    [ "$first_txn_dir" != "$second_txn_dir" ]
    [ -d "$first_txn_dir" ]
    [ -d "$second_txn_dir" ]
}

@test "transaction_begin: does nothing in non-transactional mode" {
    export DOTFILES_TRANSACTIONAL=0

    run transaction_begin

    [ "$status" -eq 0 ]
    [ -z "${DOT_TXN_DIR:-}" ]
}

@test "transaction_begin: writes journal header" {
    export DOTFILES_TRANSACTIONAL=1

    transaction_begin

    [ -f "$DOT_TXN_DIR/journal.log" ]
    local first_line
    first_line=$(head -1 "$DOT_TXN_DIR/journal.log")
    [[ "$first_line" =~ ^begin\ [0-9]+-[0-9]+\ [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]
}

@test "transaction_begin: fails gracefully when directory creation fails" {
    export DOTFILES_TRANSACTIONAL=1
    export STATE_DIR="/root/inaccessible"  # Assuming we're not running as root

    if [[ "$(id -u)" == "0" ]]; then
        skip "Running as root - cannot test directory creation failure"
    fi

    run transaction_begin

    [ "$status" -eq 1 ]
}

# =============================================================================
# TRANSACTION STAGE SYMLINK TESTS
# =============================================================================

@test "transaction_stage_symlink: creates staged symlink in transactional mode" {
    export DOTFILES_TRANSACTIONAL=1
    transaction_begin

    local src="$BATS_TEST_TMPDIR/source/test.txt"
    local dest="/home/user/.config/test.txt"

    run transaction_stage_symlink "$src" "$dest" "test-component"

    [ "$status" -eq 0 ]
    [ -L "$DOT_TXN_DIR/stage$dest" ]
    [ "$(readlink "$DOT_TXN_DIR/stage$dest")" = "$src" ]
}

@test "transaction_stage_symlink: records operation in journal" {
    export DOTFILES_TRANSACTIONAL=1
    transaction_begin

    local src="$BATS_TEST_TMPDIR/source/test.txt"
    local dest="/home/user/.config/test.txt"

    transaction_stage_symlink "$src" "$dest" "test-component"

    local journal_content
    journal_content=$(grep "^link" "$DOT_TXN_DIR/journal.log")
    [[ "$journal_content" =~ link[[:space:]]${dest}[[:space:]]${src}[[:space:]]test-component ]]
}

@test "transaction_stage_symlink: creates intermediate directories" {
    export DOTFILES_TRANSACTIONAL=1
    transaction_begin

    local src="$BATS_TEST_TMPDIR/source/test.txt"
    local dest="/home/user/.config/deep/nested/test.txt"

    transaction_stage_symlink "$src" "$dest" "test-component"

    [ -d "$DOT_TXN_DIR/stage/home/user/.config/deep/nested" ]
    [ -L "$DOT_TXN_DIR/stage$dest" ]
}

@test "transaction_stage_symlink: handles multiple staged symlinks" {
    export DOTFILES_TRANSACTIONAL=1
    transaction_begin

    local src1="$BATS_TEST_TMPDIR/source/test.txt"
    local dest1="/home/user/.config/test1.txt"
    local src2="$BATS_TEST_TMPDIR/source/test.txt"
    local dest2="/home/user/.config/test2.txt"

    transaction_stage_symlink "$src1" "$dest1" "component1"
    transaction_stage_symlink "$src2" "$dest2" "component2"

    [ -L "$DOT_TXN_DIR/stage$dest1" ]
    [ -L "$DOT_TXN_DIR/stage$dest2" ]

    local journal_lines
    journal_lines=$(grep -c "^link" "$DOT_TXN_DIR/journal.log")
    [ "$journal_lines" -eq 2 ]
}

@test "transaction_stage_symlink: bypasses staging in non-transactional mode" {
    export DOTFILES_TRANSACTIONAL=0
    export COMPONENTS_DIR="$BATS_TEST_TMPDIR/components"  # For fs_symlink
    mkdir -p "$COMPONENTS_DIR"

    local src="$BATS_TEST_TMPDIR/source/test.txt"
    local dest="$BATS_TEST_TMPDIR/target/test.txt"

    run transaction_stage_symlink "$src" "$dest" "test-component"

    [ "$status" -eq 0 ]
    [ -L "$dest" ]  # Should create real symlink immediately
    [ "$(readlink "$dest")" = "$src" ]
}

@test "transaction_stage_symlink: handles empty component parameter" {
    export DOTFILES_TRANSACTIONAL=1
    transaction_begin

    local src="$BATS_TEST_TMPDIR/source/test.txt"
    local dest="/home/user/.config/test.txt"

    transaction_stage_symlink "$src" "$dest"

    local journal_content
    journal_content=$(grep "^link" "$DOT_TXN_DIR/journal.log")
    [[ "$journal_content" =~ link[[:space:]]${dest}[[:space:]]${src}[[:space:]]$ ]]
}

# =============================================================================
# TRANSACTION COMMIT TESTS
# =============================================================================

@test "transaction_commit: executes staged symlinks" {
    export DOTFILES_TRANSACTIONAL=1
    export COMPONENTS_DIR="$BATS_TEST_TMPDIR/components"  # For fs_symlink
    mkdir -p "$COMPONENTS_DIR"

    transaction_begin

    local src="$BATS_TEST_TMPDIR/source/test.txt"
    local dest="$BATS_TEST_TMPDIR/target/test.txt"

    # Create source file and ensure target directory exists
    mkdir -p "$(dirname "$src")" "$(dirname "$dest")"
    echo "test content" > "$src"

    # Remove any existing destination
    rm -f "$dest"

    transaction_stage_symlink "$src" "$dest" "test-component"

    run transaction_commit

    [ "$status" -eq 0 ]
    [ -L "$dest" ]
    [ "$(readlink "$dest")" = "$src" ]
}

@test "transaction_commit: processes multiple staged operations" {
    export DOTFILES_TRANSACTIONAL=1
    export COMPONENTS_DIR="$BATS_TEST_TMPDIR/components"
    mkdir -p "$COMPONENTS_DIR"

    transaction_begin

    local src="$BATS_TEST_TMPDIR/source/test.txt"
    local dest1="$BATS_TEST_TMPDIR/target/test1.txt"
    local dest2="$BATS_TEST_TMPDIR/target/test2.txt"

    # Create source file and ensure target directory exists
    mkdir -p "$(dirname "$src")" "$(dirname "$dest1")"
    echo "test content" > "$src"

    # Remove any existing destinations
    rm -f "$dest1" "$dest2"

    transaction_stage_symlink "$src" "$dest1" "component1"
    transaction_stage_symlink "$src" "$dest2" "component2"

    transaction_commit

    [ -L "$dest1" ]
    [ -L "$dest2" ]
    [ "$(readlink "$dest1")" = "$src" ]
    [ "$(readlink "$dest2")" = "$src" ]
}

@test "transaction_commit: records commit in journal" {
    export DOTFILES_TRANSACTIONAL=1
    export COMPONENTS_DIR="$BATS_TEST_TMPDIR/components"
    mkdir -p "$COMPONENTS_DIR"

    transaction_begin

    local src="$BATS_TEST_TMPDIR/source/test.txt"
    local dest="$BATS_TEST_TMPDIR/target/test.txt"

    # Create source file and ensure target directory exists
    mkdir -p "$(dirname "$src")" "$(dirname "$dest")"
    echo "test content" > "$src"

    # Remove any existing destination
    rm -f "$dest"

    transaction_stage_symlink "$src" "$dest" "test-component"
    transaction_commit

    local commit_line
    commit_line=$(grep "^commit" "$DOT_TXN_DIR/journal.log")
    [[ "$commit_line" =~ ^commit\ [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]
}

@test "transaction_commit: does nothing in non-transactional mode" {
    export DOTFILES_TRANSACTIONAL=0

    run transaction_commit

    [ "$status" -eq 0 ]
}

@test "transaction_commit: handles empty transaction" {
    export DOTFILES_TRANSACTIONAL=1
    export COMPONENTS_DIR="$BATS_TEST_TMPDIR/components"
    mkdir -p "$COMPONENTS_DIR"

    transaction_begin

    run transaction_commit

    [ "$status" -eq 0 ]

    local commit_line
    commit_line=$(grep "^commit" "$DOT_TXN_DIR/journal.log")
    [[ "$commit_line" =~ ^commit ]]
}

# =============================================================================
# TRANSACTION ROLLBACK TESTS
# =============================================================================

@test "transaction_rollback: records rollback in journal" {
    export DOTFILES_TRANSACTIONAL=1
    transaction_begin

    run transaction_rollback

    [ "$status" -eq 0 ]

    local rollback_line
    rollback_line=$(grep "^rollback" "$DOT_TXN_DIR/journal.log")
    [[ "$rollback_line" =~ ^rollback\ [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]
}

@test "transaction_rollback: does nothing in non-transactional mode" {
    export DOTFILES_TRANSACTIONAL=0

    run transaction_rollback

    [ "$status" -eq 0 ]
}

@test "transaction_rollback: does not affect staged operations" {
    export DOTFILES_TRANSACTIONAL=1
    transaction_begin

    local src="$BATS_TEST_TMPDIR/source/test.txt"
    local dest="/home/user/.config/test.txt"

    transaction_stage_symlink "$src" "$dest" "test-component"

    # Staged symlink should exist
    [ -L "$DOT_TXN_DIR/stage$dest" ]

    transaction_rollback

    # Staged symlink should still exist (rollback doesn't clean up staging)
    [ -L "$DOT_TXN_DIR/stage$dest" ]

    # But rollback should be recorded
    local rollback_line
    rollback_line=$(grep "^rollback" "$DOT_TXN_DIR/journal.log")
    [[ "$rollback_line" =~ ^rollback ]]
}

# =============================================================================
# INTEGRATION AND WORKFLOW TESTS
# =============================================================================

@test "integration: complete transaction workflow" {
    export DOTFILES_TRANSACTIONAL=1
    export COMPONENTS_DIR="$BATS_TEST_TMPDIR/components"
    mkdir -p "$COMPONENTS_DIR"

    # Begin transaction
    transaction_begin
    local txn_dir="$DOT_TXN_DIR"

    # Stage multiple operations
    local src="$BATS_TEST_TMPDIR/source/test.txt"
    local dest1="$BATS_TEST_TMPDIR/target/config1.txt"
    local dest2="$BATS_TEST_TMPDIR/target/config2.txt"

    # Create source file and ensure target directories exist
    mkdir -p "$(dirname "$src")" "$(dirname "$dest1")"
    echo "test content" > "$src"

    # Remove any existing destinations
    rm -f "$dest1" "$dest2"

    transaction_stage_symlink "$src" "$dest1" "component1"
    transaction_stage_symlink "$src" "$dest2" "component2"

    # Verify staging
    [ -L "$txn_dir/stage$dest1" ]
    [ -L "$txn_dir/stage$dest2" ]
    [ ! -L "$dest1" ]  # Real symlinks shouldn't exist yet
    [ ! -L "$dest2" ]

    # Commit transaction
    transaction_commit

    # Verify final state
    [ -L "$dest1" ]
    [ -L "$dest2" ]
    [ "$(readlink "$dest1")" = "$src" ]
    [ "$(readlink "$dest2")" = "$src" ]

    # Verify journal
    local journal_content
    journal_content=$(cat "$txn_dir/journal.log")
    [[ "$journal_content" =~ begin ]]
    [[ "$journal_content" =~ link.*$dest1 ]]
    [[ "$journal_content" =~ link.*$dest2 ]]
    [[ "$journal_content" =~ commit ]]
}

@test "integration: rollback workflow" {
    export DOTFILES_TRANSACTIONAL=1
    transaction_begin
    local txn_dir="$DOT_TXN_DIR"

    # Stage operations
    local src="$BATS_TEST_TMPDIR/source/test.txt"
    local dest="$BATS_TEST_TMPDIR/target/config.txt"

    transaction_stage_symlink "$src" "$dest" "test-component"

    # Verify staging
    [ -L "$txn_dir/stage$dest" ]
    [ ! -L "$dest" ]

    # Rollback instead of commit
    transaction_rollback

    # Real symlink should not exist
    [ ! -L "$dest" ]

    # Journal should show rollback
    local journal_content
    journal_content=$(cat "$txn_dir/journal.log")
    [[ "$journal_content" =~ begin ]]
    [[ "$journal_content" =~ link.*$dest ]]
    [[ "$journal_content" =~ rollback ]]
    [[ ! "$journal_content" =~ commit ]]
}

@test "stress: many staged operations" {
    export DOTFILES_TRANSACTIONAL=1
    export COMPONENTS_DIR="$BATS_TEST_TMPDIR/components"
    mkdir -p "$COMPONENTS_DIR"

    transaction_begin

    local src="$BATS_TEST_TMPDIR/source/test.txt"

    # Create source file and ensure target directory exists
    mkdir -p "$(dirname "$src")" "$BATS_TEST_TMPDIR/target"
    echo "test content" > "$src"

    # Stage many operations
    for i in {1..50}; do
        local dest="$BATS_TEST_TMPDIR/target/config$i.txt"
        # Remove any existing destination
        rm -f "$dest"
        transaction_stage_symlink "$src" "$dest" "component$i"
    done

    # Commit all
    transaction_commit

    # Verify all symlinks created
    for i in {1..50}; do
        local dest="$BATS_TEST_TMPDIR/target/config$i.txt"
        [ -L "$dest" ]
        [ "$(readlink "$dest")" = "$src" ]
    done

    # Verify journal has correct number of operations
    local link_count
    link_count=$(grep -c "^link" "$DOT_TXN_DIR/journal.log")
    [ "$link_count" -eq 50 ]
}

# =============================================================================
# ERROR HANDLING AND EDGE CASES
# =============================================================================

@test "transaction_stage_symlink: handles paths with spaces" {
    export DOTFILES_TRANSACTIONAL=1
    transaction_begin

    local src="$BATS_TEST_TMPDIR/source/test.txt"
    local dest="/home/user/.config/file with spaces.txt"

    transaction_stage_symlink "$src" "$dest" "test component"

    [ -L "$DOT_TXN_DIR/stage$dest" ]
    [ "$(readlink "$DOT_TXN_DIR/stage$dest")" = "$src" ]

    local journal_content
    journal_content=$(grep "^link" "$DOT_TXN_DIR/journal.log")
    [[ "$journal_content" =~ file\ with\ spaces\.txt ]]
    [[ "$journal_content" =~ test\ component ]]
}

@test "transaction_stage_symlink: handles special characters in paths" {
    export DOTFILES_TRANSACTIONAL=1
    transaction_begin

    local src="$BATS_TEST_TMPDIR/source/test.txt"
    local dest="/home/user/.config/file\$with@special#chars.txt"

    transaction_stage_symlink "$src" "$dest" "test-component"

    [ -L "$DOT_TXN_DIR/stage$dest" ]
}

@test "error_handling: transaction operations without begin" {
    export DOTFILES_TRANSACTIONAL=1
    # Don't call transaction_begin

    local src="$BATS_TEST_TMPDIR/source/test.txt"
    local dest="/home/user/.config/test.txt"

    # These should fail gracefully when DOT_TXN_DIR is not set
    run transaction_stage_symlink "$src" "$dest" "test-component"
    [ "$status" -ne 0 ]

    run transaction_commit
    # Commit might succeed but do nothing

    run transaction_rollback
    # Rollback might succeed but do nothing
}

@test "environment: variables persist through transaction lifecycle" {
    export DOTFILES_TRANSACTIONAL=1

    transaction_begin
    local original_txn_dir="$DOT_TXN_DIR"

    # Create source file and target directory
    local src="$BATS_TEST_TMPDIR/source/test.txt"
    local dest="$BATS_TEST_TMPDIR/test/dest"
    mkdir -p "$(dirname "$src")" "$(dirname "$dest")"
    echo "test content" > "$src"
    rm -f "$dest"

    # DOT_TXN_DIR should persist for staging
    transaction_stage_symlink "$src" "$dest" "comp"
    [ "$DOT_TXN_DIR" = "$original_txn_dir" ]

    # And for commit
    export COMPONENTS_DIR="$BATS_TEST_TMPDIR/components"
    mkdir -p "$COMPONENTS_DIR"
    transaction_commit
    [ "$DOT_TXN_DIR" = "$original_txn_dir" ]
}
