#!/usr/bin/env bats
# tests/cli/dot.bats - Basic CLI behavior tests

load "../helpers/common.sh"

setup() {
  DOTFILES_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  export DOTFILES_ROOT
  DOT_BIN="$DOTFILES_ROOT/src/cli/bin/dot"
  [ -x "$DOT_BIN" ]
}

@test "dot --version exits 0 and prints version pattern" {
  run "$DOT_BIN" --version
  assert_success "$status"
  [[ "$output" =~ [0-9]+\.[0-9]+\.[0-9]+ ]] || { echo "Version pattern missing" >&2; return 1; }
}

@test "dot --help prints Commands section" {
  run "$DOT_BIN" --help
  assert_success "$status"
  assert_output_contains "$output" "Commands:"
}

@test "dot invalid command returns error" {
  run "$DOT_BIN" unknown-cmd-xyz
  assert_fail "$status"
  assert_output_contains "$output" "Unknown command"
}
