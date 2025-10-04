#!/usr/bin/env bash
# Portable environment helpers
set -euo pipefail

# Build a portable PATH with common language manager shims and user bins first.
env_portable_path() {
	local parts=()
	add_if() { [[ -d $1 ]] && parts+=("$1"); }

	add_if "$HOME/.pyenv/shims"
	add_if "$HOME/.rbenv/shims"
	# Choose most recent fnm multishell dir if present
	if [[ -d "$HOME/.local/state/fnm_multishells" ]]; then
		local fnm_latest
		fnm_latest=$(ls -1t "$HOME/.local/state/fnm_multishells" 2>/dev/null | head -1 || true)
		[[ -n $fnm_latest && -d "$HOME/.local/state/fnm_multishells/$fnm_latest/bin" ]] && parts+=("$HOME/.local/state/fnm_multishells/$fnm_latest/bin")
	fi
	add_if "$HOME/.cargo/bin"
	add_if "$HOME/.local/bin"
	# Homebrew (both arches) if present
	add_if "/opt/homebrew/bin"
	add_if "/usr/local/bin"
	add_if "/usr/local/sbin"
	# System paths (will already exist, but to ensure order)
	parts+=(/usr/bin /bin /usr/sbin /sbin)
	# Deduplicate while preserving order
	local out=()
	for p in "${parts[@]}"; do
		[[ -n $p ]] || continue
		if [[ ! ":${out[*]}:" == *":$p:"* ]]; then out+=("$p"); fi
	done
	local IFS=':'
	printf '%s' "${out[*]}"
}

# Export helper to easily prefix PATH when executing single commands
env_with_portable_path() {
	local portable
	portable=$(env_portable_path)
	PATH="$portable:$PATH" "$@"
}
