#!/usr/bin/env bats

setup() {
  ROOT="$(cd -- "$(dirname -- "$BATS_TEST_FILENAME")/../.." && pwd)"
  export PATH="$ROOT/src/bin:$PATH"
}

@test "status command exits 0 with current dotfiles" {
  run dot status
  [ "$status" -eq 0 ]
  echo "Status output: $output"
}
