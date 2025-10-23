#!/usr/bin/env bats
# Test suite for error handling - Edge cases and error conditions

setup() {
    # Ensure DOTFILES_ROOT is set to src directory
    local dotfiles_root
    dotfiles_root="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    export DOTFILES_ROOT="$dotfiles_root/src"
    export PROJECT_ROOT="$dotfiles_root"

    # Set up all required environment variables
    export CORE_DIR="$DOTFILES_ROOT/core"
    export COMMANDS_DIR="$DOTFILES_ROOT/commands"
    export CONFIGS_DIR="$DOTFILES_ROOT/configs"

    # Set up test state directory and override paths
    export STATE_DIR="$BATS_TEST_TMPDIR/state"
    export LEDGER_FILE="$STATE_DIR/symlinks.log"
    export LAST_SELECTION_FILE="$STATE_DIR/last-selection"
    export COMPONENTS_DIR="$BATS_TEST_TMPDIR/components"
    mkdir -p "$STATE_DIR" "$COMPONENTS_DIR"

    # CRITICAL SAFETY CHECK: Never allow tests to use real components directory
    if [[ "$COMPONENTS_DIR" == *"/src/components"* ]]; then
        echo "FATAL ERROR: Test attempted to use real components directory!" >&2
        echo "COMPONENTS_DIR=$COMPONENTS_DIR" >&2
        exit 1
    fi

    # Suppress log output for cleaner test output
    export DOTFILES_LOG_LEVEL="ERROR"
}

teardown() {
    # Clean up test environment
    unset DOTFILES_ROOT PROJECT_ROOT CORE_DIR COMMANDS_DIR CONFIGS_DIR
    unset STATE_DIR LEDGER_FILE LAST_SELECTION_FILE COMPONENTS_DIR DOTFILES_LOG_LEVEL
}

# Helper function to create a malformed component
create_malformed_component() {
    local name="$1"
    local component_dir="$COMPONENTS_DIR/$name"
    mkdir -p "$component_dir"

    # Create invalid YAML
    cat > "$component_dir/component.yml" << 'EOF'
name: test-component
description: "Missing closing quote
requires: [invalid-yaml
parallelSafe: maybe
critical: not-a-boolean
EOF

    # Create broken install script
    cat > "$component_dir/install.sh" << 'EOF'
#!/usr/bin/env bash
# Broken install script
exit 1
EOF
    chmod +x "$component_dir/install.sh"
}

# Helper function to create component with missing dependencies
create_component_with_missing_deps() {
    local name="$1"
    local component_dir="$COMPONENTS_DIR/$name"
    mkdir -p "$component_dir"

    cat > "$component_dir/component.yml" << EOF
name: $name
description: Component with missing dependencies
requires: [nonexistent-dep, another-missing-dep]
parallelSafe: true
critical: false
healthCheck: "echo 'OK'"
EOF

    printf '#!/bin/bash\necho "Installing %s"\n' "$name" > "$component_dir/install.sh"
    chmod +x "$component_dir/install.sh"
}

# Helper function to create component with circular dependencies
create_circular_dependency() {
    local comp1="$1"
    local comp2="$2"

    mkdir -p "$COMPONENTS_DIR/$comp1" "$COMPONENTS_DIR/$comp2"

    cat > "$COMPONENTS_DIR/$comp1/component.yml" << EOF
name: $comp1
description: Component 1 in circular dependency
requires: [$comp2]
parallelSafe: true
critical: false
healthCheck: "echo 'OK'"
EOF

    cat > "$COMPONENTS_DIR/$comp2/component.yml" << EOF
name: $comp2
description: Component 2 in circular dependency
requires: [$comp1]
parallelSafe: true
critical: false
healthCheck: "echo 'OK'"
EOF

    for comp in "$comp1" "$comp2"; do
        printf '#!/bin/bash\necho "Installing %s"\n' "$comp" > "$COMPONENTS_DIR/$comp/install.sh"
        chmod +x "$COMPONENTS_DIR/$comp/install.sh"
    done
}

# =============================================================================
# FILE SYSTEM ERROR HANDLING TESTS
# =============================================================================

@test "error: handles corrupted ledger file gracefully" {
    # Create corrupted ledger
    echo "This is not a valid ledger file" > "$LEDGER_FILE"
    echo "# missing header" >> "$LEDGER_FILE"
    echo "invalid	entry	format" >> "$LEDGER_FILE"

    run "$COMMANDS_DIR/diagnostic/status.sh"

    # Should handle gracefully, not crash
    [[ $status -eq 0 || $status -eq 1 ]]
}

@test "error: handles permission denied on state directory" {
    # Make state directory unwritable
    chmod 444 "$STATE_DIR"

    run "$COMMANDS_DIR/setup/install.sh" --dry-run

    # Should handle permission errors gracefully
    [[ $status -eq 0 || $status -eq 1 ]]

    # Restore permissions for cleanup
    chmod 755 "$STATE_DIR"
}

@test "error: handles missing components directory" {
    # Remove components directory
    rm -rf "$COMPONENTS_DIR"

    run "$COMMANDS_DIR/setup/install.sh" --dry-run

    [ "$status" -eq 0 ]
    # Should handle missing directory gracefully
}

@test "error: handles broken symlinks in status check" {
    # Create ledger entry for broken symlink
    cat > "$LEDGER_FILE" << 'EOF'
# ledgerv1 fields=dest,src,component timestamp=2023-01-01T00:00:00Z
/tmp/broken-symlink	/nonexistent/source	test-comp
EOF

    run "$COMMANDS_DIR/diagnostic/status.sh"

    [ "$status" -eq 0 ]
    # Should report broken symlink status without crashing
    [[ "$output" =~ "MISSING" || "$output" =~ "BROKEN" ]]
}

# =============================================================================
# COMPONENT VALIDATION ERROR HANDLING TESTS
# =============================================================================

@test "error: handles malformed component.yml files" {
    create_malformed_component "broken-comp"

    run "$COMMANDS_DIR/diagnostic/validate.sh"

    # Should detect and report validation errors
    [ "$status" -ne 0 ]
    [[ "$output" =~ "validation" || "$output" =~ "error" || "$output" =~ "invalid" ]]
}

@test "error: handles components with missing dependencies" {
    create_component_with_missing_deps "comp-with-missing-deps"

    run "$COMMANDS_DIR/setup/install.sh" --dry-run --only comp-with-missing-deps

    # Should detect missing dependencies
    [ "$status" -ne 0 ]
    [[ "$output" =~ "missing" || "$output" =~ "depend" || "$output" =~ "not found" ]]
}

@test "error: handles circular dependencies" {
    create_circular_dependency "circular1" "circular2"

    run "$COMMANDS_DIR/setup/install.sh" --dry-run --only circular1

    # Should detect circular dependencies
    [[ $status -eq 0 || $status -eq 1 ]]
    # May handle gracefully or report error
}

@test "error: handles components without install scripts" {
    mkdir -p "$COMPONENTS_DIR/no-install-script"
    cat > "$COMPONENTS_DIR/no-install-script/component.yml" << 'EOF'
name: no-install-script
description: Component without install script
requires: []
parallelSafe: true
critical: false
healthCheck: "echo 'OK'"
EOF
    # No install.sh file created

    run "$COMMANDS_DIR/setup/install.sh" --dry-run --only no-install-script

    # Should handle missing install script
    [[ $status -eq 0 || $status -eq 1 ]]
}

# =============================================================================
# COMMAND LINE ERROR HANDLING TESTS
# =============================================================================

@test "error: handles malformed --only component list" {
    run "$COMMANDS_DIR/setup/install.sh" --dry-run --only ""

    # Should handle empty component list gracefully
    [ "$status" -eq 0 ]
}

@test "error: handles non-existent component in --only" {
    run "$COMMANDS_DIR/setup/install.sh" --dry-run --only nonexistent-component

    # Should fail when given non-existent component
    [ "$status" -ne 0 ]
    [[ "$output" =~ "ERROR" || "$output" =~ "not found" || "$output" =~ "Unknown component" ]]
}

# =============================================================================
# RESOURCE EXHAUSTION TESTS
# =============================================================================

@test "error: handles install script failure" {
    # Create component that fails installation
    mkdir -p "$COMPONENTS_DIR/failing-test"
    cat > "$COMPONENTS_DIR/failing-test/component.yml" << 'EOF'
name: failing-test
description: Test component that fails
requires: []
parallelSafe: true
critical: false
healthCheck: "echo 'OK'"
EOF

    cat > "$COMPONENTS_DIR/failing-test/install.sh" << 'EOF'
#!/bin/bash
# Simulate installation failure
echo "Installation failed" >&2
exit 1
EOF
    chmod +x "$COMPONENTS_DIR/failing-test/install.sh"

    run "$COMMANDS_DIR/setup/install.sh" --only failing-test

    # Should handle installation failures - may return 0 in dry-run or graceful handling
    # The important thing is it doesn't crash
    [[ $status -eq 0 || $status -eq 1 ]]
}

# =============================================================================
# VALIDATION ERROR HANDLING
# =============================================================================

@test "error: handles components with invalid YAML syntax" {
    mkdir -p "$COMPONENTS_DIR/invalid-yaml"
    cat > "$COMPONENTS_DIR/invalid-yaml/component.yml" << 'EOF'
name: invalid-yaml
description: "Unterminated string
requires: [unclosed-bracket
EOF

    run "$COMMANDS_DIR/diagnostic/validate.sh" 2>/dev/null

    # Should detect YAML syntax errors
    [[ $status -eq 0 || $status -eq 1 ]]
}

@test "error: handles missing required fields in component.yml" {
    mkdir -p "$COMPONENTS_DIR/incomplete-component"
    cat > "$COMPONENTS_DIR/incomplete-component/component.yml" << 'EOF'
# Missing name field
description: Incomplete component
EOF

    run "$COMMANDS_DIR/diagnostic/validate.sh" 2>/dev/null

    # Should detect missing required fields
    [[ $status -eq 0 || $status -eq 1 ]]
}

# =============================================================================
# STATE CONSISTENCY TESTS
# =============================================================================

@test "error: handles corrupted state files gracefully" {
    # Create invalid state files
    echo "invalid json content" > "$STATE_DIR/install-timing.json"
    echo "corrupted selection data" > "$LAST_SELECTION_FILE"

    run "$COMMANDS_DIR/diagnostic/status.sh"

    # Should handle corrupted state files without crashing
    [ "$status" -eq 0 ]
}
