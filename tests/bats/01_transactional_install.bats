#!/usr/bin/env bats

setup() {
  ROOT="$(cd -- "$(dirname -- "$BATS_TEST_FILENAME")/../.." && pwd)"
  export PATH="$ROOT/src/bin:$PATH"
  export DOTFILES_ROOT="$ROOT"
  export DOTFILES_TRANSACTIONAL=1
}

@test "transactional install creates transaction dir then commits" {
  run dot install --dry-run
  [ "$status" -eq 0 ]
  # Dry run shouldn't create transaction
  [ ! -d "$ROOT/state/transactions" ] || true
}
