#!/usr/bin/env bats
# Tests for src2/lib/utilities/systemdetections/

setup() {
  # Load the library
  DOTFILES_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  export DOTFILES_ROOT
  export SRC_DIR="$DOTFILES_ROOT/src"
  export LIB_DIR="$SRC_DIR/lib"

  # shellcheck source=../src/lib/index.sh
  source "$LIB_DIR/index.sh"
}

# =============================================================================
# os.sh tests
# =============================================================================

@test "os_detect returns valid OS name" {
  result=$(os_detect)
  # Should be one of: macos, ubuntu, debian, fedora, rhel, arch, alpine, unknown
  [[ "$result" =~ ^(macos|ubuntu|debian|fedora|rhel|arch|alpine|unknown)$ ]]
}

@test "os_is_macos works on macOS" {
  if [[ "$(uname)" == "Darwin" ]]; then
    run os_is_macos
    [ "$status" -eq 0 ]
  else
    skip "Not running on macOS"
  fi
}

@test "os_is_linux works on Linux" {
  if [[ "$(uname)" == "Linux" ]]; then
    run os_is_linux
    [ "$status" -eq 0 ]
  else
    skip "Not running on Linux"
  fi
}

# =============================================================================
# packages.sh tests
# =============================================================================

@test "pkg_detect returns valid package manager" {
  result=$(pkg_detect)
  # Should be one of the known package managers
  [[ "$result" =~ ^(brew|apt|dnf|yum|pacman|zypper|apk|unknown)$ ]]
}

@test "pkg_detect finds brew on macOS" {
  if [[ "$(uname)" == "Darwin" ]] && command -v brew >/dev/null 2>&1; then
    result=$(pkg_detect)
    [ "$result" = "brew" ]
  else
    skip "Not running on macOS with Homebrew"
  fi
}

# =============================================================================
# commands.sh tests
# =============================================================================

@test "cmd_exists detects existing command" {
  run cmd_exists bash
  [ "$status" -eq 0 ]
}

@test "cmd_exists returns 1 for non-existent command" {
  run cmd_exists nonexistentcommand12345
  [ "$status" -eq 1 ]
}

@test "cmd_exists detects common commands" {
  # These should exist on any Unix system
  run cmd_exists ls
  [ "$status" -eq 0 ]

  run cmd_exists cat
  [ "$status" -eq 0 ]

  run cmd_exists grep
  [ "$status" -eq 0 ]
}

# =============================================================================
# term.sh tests
# =============================================================================

@test "term_width returns positive number" {
  result=$(term_width)
  # Should be a positive integer
  [[ "$result" =~ ^[0-9]+$ ]]
  [ "$result" -gt 0 ]
}

@test "term_height returns positive number" {
  result=$(term_height)
  # Should be a positive integer
  [[ "$result" =~ ^[0-9]+$ ]]
  [ "$result" -gt 0 ]
}

# =============================================================================
# env.sh tests
# =============================================================================

@test "env_is_set detects existing variable" {
  export TEST_VAR="test_value"
  run env_is_set "TEST_VAR"
  [ "$status" -eq 0 ]
  unset TEST_VAR
}

@test "env_is_set returns 1 for non-existent variable" {
  run env_is_set "NONEXISTENT_VAR_12345"
  [ "$status" -eq 1 ]
}

@test "env_get returns variable value" {
  export TEST_VAR="test_value"
  result=$(env_get "TEST_VAR")
  [ "$result" = "test_value" ]
  unset TEST_VAR
}
