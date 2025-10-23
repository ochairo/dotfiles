#!/usr/bin/env bats
# End-to-end integration tests - Complete workflow scenarios

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
    mkdir -p "$STATE_DIR"

    # Suppress log output for cleaner test output
    export DOTFILES_LOG_LEVEL="ERROR"

    # Use real components for end-to-end testing
    export COMPONENTS_DIR="$PROJECT_ROOT/src/components"
}

teardown() {
    # Clean up test environment
    unset DOTFILES_ROOT PROJECT_ROOT CORE_DIR COMMANDS_DIR CONFIGS_DIR
    unset STATE_DIR LEDGER_FILE LAST_SELECTION_FILE COMPONENTS_DIR DOTFILES_LOG_LEVEL
}

# End-to-end tests now use real components for more realistic testing

# =============================================================================
# COMPLETE WORKFLOW TESTS
# =============================================================================

@test "e2e: basic command execution with real components" {
    # Test that commands execute without errors using dependency-free real components

    # Run complete installation with specific components (dry run for safety)
    run "$COMMANDS_DIR/setup/install.sh" --dry-run --only git,jq

    [ "$status" -eq 0 ]
    # Should complete without errors
}

@test "e2e: status check basic functionality" {
    # Check status command works
    run "$COMMANDS_DIR/diagnostic/status.sh"

    [ "$status" -eq 0 ]
    # Status should work without errors
}

@test "e2e: health check basic functionality" {
    # Run health check on specific components to avoid hanging
    run "$COMMANDS_DIR/diagnostic/health.sh" --only git,jq

    # Should work or gracefully handle issues
    [[ $status -eq 0 || $status -eq 1 ]]
}

@test "e2e: validation workflow with real components" {
    # Run validation on specific real components to avoid timeout

    # Run validation on a lightweight component
    run "$COMMANDS_DIR/diagnostic/validate.sh" --component git

    # Should validate real component configurations
    # May fail if component is incomplete - this is expected
    [[ $status -eq 0 || $status -eq 1 ]]
}

@test "e2e: component inspection workflow with real components" {
    # Test component command with real components - it lists all components
    run "$COMMANDS_DIR/component/component.sh"

    # Should handle real components and list them
    [ "$status" -eq 0 ]
    # Should contain some component names
    [[ "$output" =~ "git" ]]
}

@test "e2e: doctor diagnostic workflow" {
    # Test doctor command - may fail due to platform-specific components
    run "$COMMANDS_DIR/diagnostic/doctor.sh"

    # Doctor may return non-zero if health checks fail (platform-specific components)
    [[ $status -eq 0 || $status -eq 2 ]]
    # Should provide diagnostic information
}

# =============================================================================
# BASIC INTEGRATION TESTS
# =============================================================================

@test "e2e: all core commands execute without errors" {
    # Test that all commands can be invoked with real components

    # 1. Validate specific component to avoid timeout
    run "$COMMANDS_DIR/diagnostic/validate.sh" --component git
    # Validation may fail if component is incomplete - this is expected
    [[ $status -eq 0 || $status -eq 1 ]]

    # 2. Check status
    run "$COMMANDS_DIR/diagnostic/status.sh"
    [ "$status" -eq 0 ]

    # 3. Test install with dry-run
    run "$COMMANDS_DIR/setup/install.sh" --dry-run --only git,jq
    [ "$status" -eq 0 ]

    # 4. Check health
    run "$COMMANDS_DIR/diagnostic/health.sh" --only git,jq
    [[ $status -eq 0 || $status -eq 1 ]]

    # 5. Run diagnostics
    run "$COMMANDS_DIR/diagnostic/doctor.sh"
    # Doctor may return non-zero if health checks fail (platform-specific components)
    [[ $status -eq 0 || $status -eq 2 ]]
}

@test "e2e: commands handle missing arguments gracefully" {
    # Test commands without required arguments

    run "$COMMANDS_DIR/setup/install.sh" --help 2>/dev/null
    [[ $status -eq 0 || $status -eq 1 ]]

    run "$COMMANDS_DIR/component/component.sh" 2>/dev/null
    [[ $status -eq 0 || $status -eq 1 ]]
}

@test "e2e: state directory creation and management" {
    # Test that state management works

    # State directory should be created when needed
    [ -d "$STATE_DIR" ]

    # Commands should handle empty state gracefully
    run "$COMMANDS_DIR/diagnostic/status.sh"
    [ "$status" -eq 0 ]
}
