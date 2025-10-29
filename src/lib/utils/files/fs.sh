#!/usr/bin/env bash
# files/fs.sh - Consolidated filesystem helpers (migrated from legacy filesystem/ and filesystem.sh)
# Provides: fs_mkdir fs_remove_dir fs_is_empty fs_dir_size fs_copy_dir
#           fs_make_executable fs_add_to_path fs_mktemp fs_mktemp_file
#           fs_trap_cleanup fs_is_absolute fs_absolute fs_symlink

[[ -n "${FS_HELPERS_LOADED:-}" ]] && return 0
readonly FS_HELPERS_LOADED=1

# Directory ops
fs_mkdir() { local dir="$1" perms="${2:-755}"; [[ -z $dir ]] && { msg_error "fs_mkdir: dir required"; return 1; }; [[ -d $dir ]] && return 0; mkdir -p "$dir" && chmod "$perms" "$dir"; }
fs_remove_dir() { local dir="$1"; [[ -d $dir ]] && rm -rf "$dir"; }
fs_is_empty() { local dir="$1"; [[ -d $dir ]] || return 1; [[ -z $(ls -A "$dir") ]]; }
fs_dir_size() { local dir="$1"; [[ -d $dir ]] || { echo 0; return 1; }; if command -v du >/dev/null 2>&1; then du -sb "$dir" 2>/dev/null | cut -f1 || echo 0; else echo 0; fi; }
fs_copy_dir() { local src="$1" dest="$2"; [[ -d $src ]] || return 1; cp -a "$src" "$dest"; }

# Executable / permissions
fs_make_executable() { local file="$1"; [[ -f $file ]] || return 1; chmod +x "$file"; }

# PATH / path helpers
fs_add_to_path() {
  local dir="$1" rc_file="${2:-}"; [[ -d $dir ]] || return 1
  if [[ -z $rc_file ]]; then
    if [[ -n ${ZSH_VERSION:-} ]]; then rc_file="$HOME/.zshrc";
    elif [[ -n ${BASH_VERSION:-} ]]; then rc_file="$HOME/.bashrc";
    else rc_file="$HOME/.profile"; fi
  fi
  if [[ -f $rc_file ]] && grep -q "PATH.*$dir" "$rc_file"; then return 0; fi
  { echo ""; echo "# Added by dotfiles"; echo "export PATH=\"$dir:$PATH\""; } >>"$rc_file"
}
fs_is_absolute() { [[ ${1} = /* ]]; }
fs_absolute() { local path="$1"; if fs_is_absolute "$path"; then echo "$path"; else echo "$(cd "$(dirname "$path")" && pwd)/$(basename "$path")"; fi }

# Temp resources
fs_mktemp() { mktemp -d 2>/dev/null || mktemp -d -t 'tmpdir'; }
fs_mktemp_file() { mktemp 2>/dev/null || mktemp -t 'tmpfile'; }

# Cleanup trap
fs_trap_cleanup() { local cleanup_cmd="$1"; trap '$cleanup_cmd' EXIT INT TERM; }

# Symlink (ledger-aware via core linker service if loaded)
fs_symlink() {
  local source="$1" target="$2" component="${3:-filesystem}"
  if declare -F symlinks_create >/dev/null 2>&1; then
    symlinks_create "$source" "$target" "$component"
    return $?
  fi
  # Fallback simple force link (no backup / ledger)
  [[ -e "$source" ]] || return 1
  mkdir -p "$(dirname "$target")"
  ln -sf "$source" "$target"
}

export -f \
  fs_mkdir fs_remove_dir fs_is_empty fs_dir_size fs_copy_dir \
  fs_make_executable fs_add_to_path fs_mktemp fs_mktemp_file \
  fs_trap_cleanup fs_is_absolute fs_absolute fs_symlink
