#!/usr/bin/env bash
# fonts post-install script: install JetBrainsMono Nerd Font on non-macOS/non-Arch systems
set -euo pipefail

# Skip if macOS or Arch (handled by package manager)
UNAME="$(uname -s)"
if [[ "${UNAME}" == "Darwin" ]]; then
  msg_dim "macOS uses brew cask for fonts; skipping manual font install"
  return 0
fi

# If Arch (pacman/yay install), skip
if command -v pacman >/dev/null 2>&1 || command -v yay >/dev/null 2>&1; then
  msg_dim "Arch-based system uses package for fonts; skipping manual font install"
  return 0
fi

ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
TMPDIR="$(mktemp -d)"
FONT_ZIP="${TMPDIR}/font.zip"
TARGET_DIR="${HOME}/.local/share/fonts"

msg_info "Downloading JetBrainsMono Nerd Font..."
if curl -fsSL -o "${FONT_ZIP}" "${ZIP_URL}"; then
  msg_success "Download complete"
else
  msg_error "Failed to download font archive"
  rm -rf "${TMPDIR}"
  return 1
fi

msg_info "Extracting fonts..."
if unzip -q "${FONT_ZIP}" -d "${TMPDIR}"; then
  mkdir -p "${TARGET_DIR}"
  find "${TMPDIR}" -name "*.ttf" -exec cp {} "${TARGET_DIR}/" \;
  msg_success "Fonts copied to ${TARGET_DIR}"
else
  msg_error "Failed to extract font archive"
  rm -rf "${TMPDIR}"
  return 1
fi

# Refresh font cache if available
if command -v fc-cache >/dev/null 2>&1; then
  msg_info "Refreshing font cache..."
  if fc-cache -fv >/dev/null 2>&1; then
    msg_success "Font cache refreshed"
  else
    msg_warn "Font cache refresh failed"
  fi
else
  msg_dim "fc-cache not available; skipping cache refresh"
fi

rm -rf "${TMPDIR}"
msg_success "JetBrainsMono Nerd Font installation complete"
