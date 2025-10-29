#!/usr/bin/env bash
# Starship post-install configuration script
# Links the starship configuration directory into $HOME/.config/starship

set -euo pipefail

# Prefer consolidated fs utilities; fall back silently if not present
# shellcheck source=/dev/null
if [[ -f "${DOTFILES_ROOT}/src/lib/utils/files/fs.sh" ]]; then
  # shellcheck disable=SC1091
  source "${DOTFILES_ROOT}/src/lib/utils/files/fs.sh"
fi

# Resolve configuration directory from multiple possible locations to handle
# repository layout variations (legacy vs current structure).
_starship_config_source="${DOTFILES_ROOT}/src/configs/starship"
[[ -d "${_starship_config_source}" ]] || _starship_config_source=""

TARGET_DIR="${HOME}/.config/starship"

if [[ -z "${_starship_config_source}" ]]; then
  msg_warn "Starship config directory not found (checked src/configs & configs)"
  msg_dim "Checked canonical path: ${DOTFILES_ROOT}/src/configs/starship"
  return 0
fi

# Link configuration directory
if fs_symlink "${_starship_config_source}" "${TARGET_DIR}" "starship"; then
  msg_success "Starship configuration linked from ${_starship_config_source}"
else
  msg_error "Failed to link starship configuration from ${_starship_config_source}"
  return 1
fi
