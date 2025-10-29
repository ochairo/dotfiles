#!/usr/bin/env bats
# tests/lib/errors.bats

load "../helpers/common.sh"

setup() {
  DOTFILES_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  export DOTFILES_ROOT
  source "$DOTFILES_ROOT/src/lib/index.sh"
}

@test "errors loader guard" {
  run bash -c "source '$DOTFILES_ROOT/src/lib/utils/errors/errors.sh'; echo $ERRORS_MODULE_LOADED"
  [ "$status" -eq 0 ]
  [[ "$output" == "1" ]]
}

@test "errors_retry executes specified attempts" {
  run bash -c "attempts=0; source '$DOTFILES_ROOT/src/lib/utils/errors/errors.sh'; errors_retry 3 0.01 bash -c 'attempts=\$((attempts+1))'; echo \$attempts"
  [ "$status" -eq 0 ]
  [ "$output" -eq 3 ]
}

@test "errors_safe exposes exit code" {
  run bash -c 'source '"$DOTFILES_ROOT"'/src/lib/utils/errors/errors.sh; errors_safe bash -c "exit 7"; echo SAFE_ERR=$SAFE_ERR'
  [ "$status" -eq 0 ]
  assert_output_contains "$output" "SAFE_ERR=7"
}
