#!/usr/bin/env bats
# Tests for src2/core/ modules

setup() {
  # Load libraries
  DOTFILES_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  export DOTFILES_ROOT
  export SRC_DIR="$DOTFILES_ROOT/src"
  export LIB_DIR="$SRC_DIR/lib"
  export CORE_DIR="$SRC_DIR/core"
  export COMPONENTS_DIR="$SRC_DIR/components"

  # Use temp ledger for testing
  export DOTFILES_LEDGER="$BATS_TMPDIR/test_ledger_$$"

  # shellcheck source=../src/lib/index.sh
  source "$LIB_DIR/index.sh"

  # shellcheck source=../src/core/index.sh
  source "$CORE_DIR/index.sh"
}

teardown() {
  # Cleanup temp ledger
  rm -f "$DOTFILES_LEDGER"
}

# =============================================================================
# ledger.sh tests
# =============================================================================

@test "ledger_init creates ledger file" {
  rm -f "$DOTFILES_LEDGER"
  run ledger_init
  [ "$status" -eq 0 ]
  [ -f "$DOTFILES_LEDGER" ]
}

@test "ledger_add adds entry to ledger" {
  ledger_init

  run ledger_add "symlink" "test-component" "$HOME/.testfile" "/source/file"
  [ "$status" -eq 0 ]

  # Check entry was added
  grep -q "test-component" "$DOTFILES_LEDGER"
}

@test "ledger_has detects tracked target" {
  ledger_init
  ledger_add "symlink" "test" "$HOME/.testfile" "/source"

  run ledger_has "$HOME/.testfile"
  [ "$status" -eq 0 ]
}

@test "ledger_has returns 1 for untracked target" {
  ledger_init

  run ledger_has "/nonexistent/path"
  [ "$status" -eq 1 ]
}

@test "ledger_entries returns all entries" {
  ledger_init
  ledger_add "symlink" "comp1" "/target1" "/source1"
  ledger_add "symlink" "comp2" "/target2" "/source2"

  result=$(ledger_count)
  [ "$result" -ge 2 ]
}

# =============================================================================
# register.sh tests (if component registry functions exist)
# =============================================================================

@test "components directory exists" {
  [ -d "$COMPONENTS_DIR" ]
}

@test "components directory has YAML files" {
  yaml_count=$(find "$COMPONENTS_DIR" -name "component.yml" -o -name "*.yml" | wc -l)
  [ "$yaml_count" -gt 0 ]
}

# =============================================================================
# Core module loading tests
# =============================================================================

@test "core/index.sh loads without errors" {
  # Should have already loaded in setup
  [ -n "$DOTFILES_INDEX_LOADED" ]
}

@test "DOTFILES_CORE_DIR is set" {
  [ -n "$DOTFILES_CORE_DIR" ]
}

@test "ledger functions are available" {
  type -t ledger_init >/dev/null
  type -t ledger_add >/dev/null
  type -t ledger_has >/dev/null
}
