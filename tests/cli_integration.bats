#!/usr/bin/env bats
# Integration tests for src2/cli/bin/dot

setup() {
  export DOTFILES_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  export DOT_BIN="$DOTFILES_ROOT/src/cli/bin/dot"

  # Ensure dot is executable
  [ -x "$DOT_BIN" ]
}

# =============================================================================
# Basic CLI tests
# =============================================================================

@test "dot --version shows version" {
  run "$DOT_BIN" --version
  [ "$status" -eq 0 ]
  [[ "$output" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]
}

@test "dot --help shows help" {
  run "$DOT_BIN" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Commands:"* ]]
}

@test "dot -h shows help" {
  run "$DOT_BIN" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Commands:"* ]]
}

@test "dot without args shows help" {
  run "$DOT_BIN"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Commands:"* ]]
}

@test "dot with invalid command shows error" {
  run "$DOT_BIN" nonexistent-command
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown command"* ]]
}

# =============================================================================
# Command discovery tests
# =============================================================================

@test "dot --help lists diagnostic commands" {
  run "$DOT_BIN" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Diagnostic:"* ]]
}

@test "dot --help lists component commands" {
  run "$DOT_BIN" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Components:"* ]]
}

@test "dot --help lists maintenance commands" {
  run "$DOT_BIN" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Maintenance:"* ]]
}

# =============================================================================
# Path resolution tests
# =============================================================================

@test "dot sets DOTFILES_ROOT correctly" {
  # Run with debug to see paths
  run bash -c "DOTFILES_DEBUG=1 '$DOT_BIN' --version 2>&1 | grep DOTFILES_ROOT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"DOTFILES_ROOT:"* ]]
}

@test "dot finds lib directory" {
  run bash -c "DOTFILES_DEBUG=1 '$DOT_BIN' --version 2>&1 | grep LIB_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"/src/lib"* ]]
}

@test "dot finds core directory" {
  run bash -c "DOTFILES_DEBUG=1 '$DOT_BIN' --version 2>&1 | grep CORE_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"/src/core"* ]]
}

@test "dot finds components directory" {
  run bash -c "DOTFILES_DEBUG=1 '$DOT_BIN' --version 2>&1 | grep COMPONENTS_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"/src/components"* ]]
}

# =============================================================================
# Library loading tests
# =============================================================================

@test "dot loads lib/index.sh successfully" {
  # If it doesn't load, dot will fail
  run "$DOT_BIN" --version
  [ "$status" -eq 0 ]
}

@test "dot loads core/index.sh successfully" {
  # If it doesn't load, dot will fail
  run "$DOT_BIN" --version
  [ "$status" -eq 0 ]
}

# =============================================================================
# Environment variable tests
# =============================================================================

@test "DOTFILES_DEBUG enables debug output" {
  run bash -c "DOTFILES_DEBUG=1 '$DOT_BIN' --version 2>&1"
  [ "$status" -eq 0 ]
  [[ "$output" == *"DOTFILES_ROOT"* ]]
}

@test "DOTFILES_LEDGER can be overridden" {
  custom_ledger="$BATS_TMPDIR/custom_ledger_$$"
  run bash -c "DOTFILES_LEDGER='$custom_ledger' DOTFILES_DEBUG=1 '$DOT_BIN' --version 2>&1 | grep DOTFILES_LEDGER"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$custom_ledger"* ]]
}
