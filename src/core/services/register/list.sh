#!/usr/bin/env bash
# register/list.sh - Listing & counting
components_list() {
  # Derive directory robustly each call (avoids earlier init order issues)
  local dir="${COMPONENTS_DIR:-}" root="${DOTFILES_ROOT:-}" script_dir
  if [[ -z "$dir" ]]; then
    if [[ -n "$root" && -d "$root/src/components" ]]; then
      dir="$root/src/components"
    else
      # Fallback: relative to this file (../../../../src/components)
      script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)"
      # script_dir = .../core/services/register ; ascend three levels to repo root
      local repo_root="$(cd "$script_dir/../../../.." && pwd)"
      [[ -d "$repo_root/src/components" ]] && dir="$repo_root/src/components" || dir=""
    fi
  fi
  if [[ "${DOTFILES_DEBUG:-0}" == 1 ]]; then
    msg_dim "DEBUG: components_list resolved dir='$dir' exists=$([[ -d "$dir" ]] && echo yes || echo no)"
  fi
  [[ -z "$dir" || ! -d "$dir" ]] && return 0
  find "$dir" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
}
components_count() { components_list | wc -l | tr -d ' '; }

# Compatibility aliases (legacy API)
registry_list_components() { components_list; }
registry_components_count() { components_count; }
export -f registry_list_components registry_components_count
