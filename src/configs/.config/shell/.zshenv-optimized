# Optimized zshenv - only essential environment variables
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# XDG base
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Oh My Zsh (if not in fast mode)
if [[ "$FAST_TERMINAL" != "1" ]]; then
  export ZSH="$HOME/.oh-my-zsh"
  export ZSH_THEME="robbyrussell"

  # Zsh autosuggestions optimization
  export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  export ZSH_AUTOSUGGEST_USE_ASYNC=1
  export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244"

  # Starship config (only if exists)
  if [[ -n "$DOTFILES_ROOT" && -f "$DOTFILES_ROOT/configs/.config/starship/starship.toml" ]]; then
    export STARSHIP_CONFIG="$DOTFILES_ROOT/configs/.config/starship/starship.toml"
  elif [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml" ]]; then
    export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml"
  fi
fi

# Essential PATH only
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Lazy PATH additions (only in normal shells)
if [[ "$FAST_TERMINAL" != "1" ]]; then
  # Defer heavy PATH operations to .zshrc
  export DEFER_PATH_SETUP=1
fi
