#!/usr/bin/env bats
# tests/lib/utils/parallel.bats - Tests for parallel module after utils/ rename

load "../../helpers/common.sh"

setup() {
  DOTFILES_ROOT="$(cd "$BATS_TEST_DIRNAME/../../.." && pwd)"
  export DOTFILES_ROOT
  source "$DOTFILES_ROOT/src/lib/index.sh"
}

@test "parallel loader guard" {
  run bash -c "source '$DOTFILES_ROOT/src/lib/utils/parallel/parallel.sh'; echo $PARALLEL_MODULE_LOADED"
  [ "$status" -eq 0 ]
  [[ "$output" == "1" ]]
}

@test "parallel map over items creates expected output entries" {
  run bash -c 'source '"$DOTFILES_ROOT"'/src/lib/utils/parallel/parallel.sh; PARALLEL_STRATEGY=sequential; parallel_map echo a b c'
  [ "$status" -eq 0 ]
  assert_output_contains "$output" "a"
  assert_output_contains "$output" "b"
  assert_output_contains "$output" "c"
}
