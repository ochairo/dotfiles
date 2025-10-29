#!/usr/bin/env bats
# config.bats - tests for ui_config_load (prototype)

setup() {
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)"
  source "$PROJECT_ROOT/src/lib/ui/index.sh"
}

@test "config load sets env overrides" {
  cfg="$BATS_TEST_TMPDIR/test.cfg"
  cat > "$cfg" <<EOF
min_rows: 8
responsive: true
debug: false
EOF
  ui_config_load "$cfg"
  [ "$DOTFILES_MIN_CONTENT_ROWS" -eq 8 ]
  [ "$DOTFILES_RESPONSIVE" -eq 1 ]
  [ "${DOTFILES_UI_DEBUG:-0}" -eq 0 ]
  [ "$UI_ENV_MIN_ROWS" -eq 8 ]
}

@test "invalid key ignored" {
  cfg="$BATS_TEST_TMPDIR/test2.cfg"
  cat > "$cfg" <<EOF
unknown: value
min_rows: 5
EOF
  ui_config_load "$cfg"
  [ "$DOTFILES_MIN_CONTENT_ROWS" -eq 5 ]
}
