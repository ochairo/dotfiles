#!/usr/bin/env bats
# env.bats - tests for env/env.sh snapshot variables

setup() {
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)"
}

@test "env resolves default min rows" {
  unset DOTFILES_MIN_CONTENT_ROWS
  source "$PROJECT_ROOT/src/lib/ui/env/env.sh"
  [ "$UI_ENV_MIN_ROWS" -eq 3 ]
}

@test "env overrides min rows via DOTFILES_MIN_CONTENT_ROWS" {
  DOTFILES_MIN_CONTENT_ROWS=7
  source "$PROJECT_ROOT/src/lib/ui/env/env.sh"
  [ "$UI_ENV_MIN_ROWS" -eq 7 ]
}

@test "env boolean flags map to 1" {
  DOTFILES_RESPONSIVE=1 DOTFILES_UI_DEBUG=1
  source "$PROJECT_ROOT/src/lib/ui/env/env.sh"
  [ "$UI_ENV_RESPONSIVE" -eq 1 ]
  [ "$UI_ENV_DEBUG" -eq 1 ]
}
