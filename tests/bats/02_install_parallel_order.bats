#!/usr/bin/env bats

setup() {
  ROOT="$(cd -- "$(dirname -- "$BATS_TEST_FILENAME")/../.." && pwd)"
  export PATH="$ROOT/src/bin:$PATH"
  export DOTFILES_ROOT="$ROOT"
  # Source constants to get STATE_DIR
  source "$ROOT/src/core/constants.sh"
}

@test "parallel install still saves selection" {
  run dot install --parallel --dry-run
  [ "$status" -eq 0 ]
  [ -f "$STATE_DIR/last-selection" ]
}
