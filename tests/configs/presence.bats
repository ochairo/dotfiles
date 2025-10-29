#!/usr/bin/env bats
# tests/configs/presence.bats - Ensure all expected config directories exist & non-empty

load "../helpers/common.sh"

setup() {
  DOTFILES_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  export DOTFILES_ROOT
  CONFIGS_DIR="$DOTFILES_ROOT/src/configs"
}

@test "configs directory exists" { [ -d "$CONFIGS_DIR" ]; }

@test "expected config subdirectories exist" {
  for d in dircolors fzf lima nvim ripgrep shell starship wezterm zellij; do
    [ -d "$CONFIGS_DIR/$d" ] || { echo "Missing $d" >&2; return 1; }
  done
}

@test "each config directory not empty" {
  for d in dircolors fzf lima nvim ripgrep shell starship wezterm zellij; do
    cnt=$(find "$CONFIGS_DIR/$d" -type f | head -n1 | wc -l)
    [ "$cnt" -ge 1 ] || { echo "Empty config: $d" >&2; return 1; }
  done
}
