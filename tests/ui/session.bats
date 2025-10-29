#!/usr/bin/env bats
# session.bats - tests for ui_session_begin/ui_session_end with responsive + debug

setup() {
  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)"
  source "$PROJECT_ROOT/src/lib/ui/index.sh"
}

teardown() {
  ui_session_end 2>/dev/null || true
}

# Simple renderer increments a counter
renderer_calls=0
renderer_fn() { renderer_calls=$((renderer_calls+1)); }
resize_cb_calls=0
resize_cb() { resize_cb_calls=$((resize_cb_calls+1)); }

@test "session begins and calls renderer once" {
  DOTFILES_RESPONSIVE=0 DOTFILES_UI_DEBUG=0 ui_session_begin renderer_fn
  [ "$renderer_calls" -eq 1 ]
}

@test "responsive session traps SIGWINCH and invokes resize + renderer" {
  renderer_calls=0; resize_cb_calls=0
  DOTFILES_RESPONSIVE=1 DOTFILES_UI_DEBUG=0 ui_session_begin renderer_fn resize_cb
  # Simulate resize
  kill -WINCH $$
  sleep 0.1
  [ "$renderer_calls" -ge 2 ]
  [ "$resize_cb_calls" -ge 1 ]
}

@test "debug mode emits session begin line" {
  renderer_calls=0
  DOTFILES_RESPONSIVE=0 DOTFILES_UI_DEBUG=1 run ui_session_begin renderer_fn
  echo "$output" | grep -q "\[session\] begin"
}
