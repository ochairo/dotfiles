#!/usr/bin/env bats
# tests/components/registry.bats - Component presence and readability

load "../helpers/common.sh"

setup() {
  DOTFILES_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  export DOTFILES_ROOT
  COMPONENTS_DIR="$DOTFILES_ROOT/src/components"
  export COMPONENTS_DIR
}

@test "components directory exists" { [ -d "$COMPONENTS_DIR" ]; }

@test "at least one component.yml exists" {
  run bash -c "find \"$COMPONENTS_DIR\" -maxdepth 2 -type f -name component.yml | wc -l"
  [ "$status" -eq 0 ]
  [ "$output" -ge 1 ]
}

@test "all component.yml files are non-empty" {
  run bash -c '[ -d "$COMPONENTS_DIR" ] || { echo "skip: components dir missing"; exit 0; }; count=$(find "$COMPONENTS_DIR" -maxdepth 2 -type f -name component.yml -not -empty | wc -l | tr -d " "); total=$(find "$COMPONENTS_DIR" -maxdepth 2 -type f -name component.yml | wc -l | tr -d " "); [ "$count" -eq "$total" ]'
  [ "$status" -eq 0 ]
}
