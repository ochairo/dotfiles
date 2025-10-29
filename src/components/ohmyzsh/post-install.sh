#!/usr/bin/env bash
# ohmyzsh post-install script: ensure template exists and link .zshrc
set -euo pipefail

OMZ_DIR="${HOME}/.oh-my-zsh"
TEMPLATE_PATH="${OMZ_DIR}/templates/zshrc.zsh-template"

# Create a minimal template if missing
if [[ ! -f "${TEMPLATE_PATH}" ]]; then
  mkdir -p "$(dirname "${TEMPLATE_PATH}")"
  cat > "${TEMPLATE_PATH}" <<'TEMPLATE_EOF'
#!/usr/bin/env zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
if [ -d "$ZSH" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi
TEMPLATE_EOF
  msg_info "Generated default .zshrc template"
else
  msg_dim "Template already exists: ${TEMPLATE_PATH}"
fi

# Provide fs_symlink compatibility if legacy core/fs.sh isn't present
if ! declare -F fs_symlink >/dev/null 2>&1; then
  # Ensure symlink utilities are available
  [[ -f "${DOTFILES_ROOT}/src/lib/index.sh" ]] && source "${DOTFILES_ROOT}/src/lib/index.sh"
  if declare -F symlink_force >/dev/null 2>&1; then
    fs_symlink() { symlink_force "$1" "$2"; }
  else
    fs_symlink() { ln -sf "$1" "$2"; }
  fi
fi

# Symlink template to ~/.zshrc (ledger tracked)
if [[ -f "${TEMPLATE_PATH}" ]]; then
  fs_symlink "${TEMPLATE_PATH}" "${HOME}/.zshrc" "ohmyzsh" || { msg_error "Failed to link .zshrc"; return 1; }
  msg_success ".zshrc linked to Oh My Zsh template"
else
  msg_error "Template missing after generation attempt: ${TEMPLATE_PATH}"
  return 1
fi
