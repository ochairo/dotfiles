#!/usr/bin/env bats
# tests/core/wizard.bats

load "../helpers/common.sh"

setup() {
  DOTFILES_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  export DOTFILES_ROOT
}

@test "wizard loader guard" {
  run bash -c "source '$DOTFILES_ROOT/src/core/orchestrators/wizard.sh'; if [[ -n \${DOTFILES_WIZARD_LOADED:-} ]]; then echo 1; else echo 0; fi"
  [ "$status" -eq 0 ]
  [[ "$output" == "1" ]]
}

@test "wizard functions are available" {
  run bash -c "source '$DOTFILES_ROOT/src/core/orchestrators/wizard.sh'; declare -F | grep -E 'wizard_select|wizard_confirm' | wc -l"
  [ "$status" -eq 0 ]
  # At least one function expected
  [ "$output" -ge 1 ]
}
