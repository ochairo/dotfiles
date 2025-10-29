#!/bin/bash

# Shell environment for macOS and Linux compatibility
# Optimized shell environment - only essential environment variables

# Dotfiles repository root (auto-detect from symlink or set manually)
if [[ -z "$DOTFILES_ROOT" ]]; then
  # Try to detect from .zshenv symlink location
  if [[ -L "$HOME/.zshenv" ]]; then
    # .zshenv is at: dotfiles/src/configs/.config/shell/.zshenv
    # Go up: shell -> .config -> configs -> src -> dotfiles (5 levels)
    DOTFILES_ROOT="$(cd "$(dirname "$(readlink "$HOME/.zshenv")")/../../../.." && pwd)"
  else
    # Fallback: assume standard location
    DOTFILES_ROOT="${HOME}/dotfiles"
  fi
fi
export DOTFILES_ROOT

export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# XDG base
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="robbyrussell"

# Zsh autosuggestions optimization
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244"

# Starship config (only if exists)
if [[ -n "$DOTFILES_ROOT" && -f "$DOTFILES_ROOT/src/configs/.config/starship/starship.toml" ]]; then
  export STARSHIP_CONFIG="$DOTFILES_ROOT/src/configs/.config/starship/starship.toml"
elif [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml" ]]; then
  export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml"
fi

# Essential PATH only
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Defer heavy PATH operations to .zshrc
export DEFER_PATH_SETUP=1
