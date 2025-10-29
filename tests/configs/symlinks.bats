#!/usr/bin/env bats
# tests/configs/symlinks.bats - Validate CONFIG_SOURCE and SHELL_CONFIG_DIR paths resolve & use new layout

load "../helpers/common.sh"

setup() {
  DOTFILES_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  export DOTFILES_ROOT
}

@test "component CONFIG_SOURCE directories exist and not using deprecated .config" {
  while IFS= read -r line; do
  path=$(echo "$line" | sed -E 's/.*CONFIG_SOURCE=\"([^\"]+)\".*/\1/')
  expanded=$(eval "echo $path")
    [[ "$expanded" != *"/src/configs/.config/"* ]] || { echo "Deprecated path segment in: $expanded" >&2; return 1; }
    [[ -d "$expanded" ]] || { echo "Missing config directory: $expanded" >&2; return 1; }
  done < <(grep -R "CONFIG_SOURCE=\"" "$DOTFILES_ROOT/src/components"/*/component.yml || true)
}

@test "zsh config directory present" {
  dir="${DOTFILES_ROOT}/src/configs/shell"; [[ -d "$dir" ]] || { echo "Missing shell config directory: $dir" >&2; return 1; }
}
