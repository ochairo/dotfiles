# Optimized Zsh configuration

# Ultra-fast mode for floating terminals
if [[ "$FAST_TERMINAL" == "1" ]]; then
  source "$HOME/.zshrc-fast"
  return
fi

# Normal shell configuration with performance optimizations
# History settings
HISTFILE=${HISTFILE:-$HOME/.zsh_history}
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_FIND_NO_DUPS SHARE_HISTORY INC_APPEND_HISTORY

# Load lazy loading utilities
source "$HOME/.zsh_lazy"

# Load performance optimizations
[[ -f "$HOME/.zsh_performance" ]] && source "$HOME/.zsh_performance"

# Load safety mechanisms (process monitoring and cleanup)
[[ -f "$HOME/.zsh_safety" ]] && source "$HOME/.zsh_safety"

# Setup extended PATH if deferred
[[ "$DEFER_PATH_SETUP" == "1" ]] && setup_extended_path

# Oh My Zsh with performance optimizations
if [[ -d "$ZSH" ]]; then
  # Optimize plugin loading - only essential plugins
  plugins=(git fast-syntax-highlighting zsh-autosuggestions)  # Minimal but useful set

  # Fast completions
  local zc="${ZSH_CUSTOM:-$ZSH/custom}/plugins"
  [[ -d "$zc/zsh-completions/src" ]] && fpath=("$zc/zsh-completions/src" $fpath)

  # Load Oh My Zsh
  source "$ZSH/oh-my-zsh.sh"

  # Ultra-fast completion initialization
  autoload -Uz compinit
  # Only rebuild completions once per day and use cache
  local zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
  if [[ $zcompdump(#qNmh+24) ]]; then
    compinit -C -d "$zcompdump"  # Skip security check and specify dump file
  else
    compinit -d "$zcompdump"
    # Compile the completion dump for faster loading
    [[ -f "$zcompdump" && ! -f "${zcompdump}.zwc" ]] && zcompile "$zcompdump"
  fi
fi

# Load additional plugins after Oh My Zsh (for better compatibility)
if [[ -d "${ZSH_CUSTOM:-$ZSH/custom}/plugins" ]]; then
  local custom_plugins="${ZSH_CUSTOM:-$ZSH/custom}/plugins"

  # Load syntax highlighting (fast version)
  [[ -f "$custom_plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]] && \
    source "$custom_plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

  # Load autosuggestions (already optimized in .zshenv)
  [[ -f "$custom_plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
    source "$custom_plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

  # Load fzf-tab (lightweight)
  [[ -f "$custom_plugins/fzf-tab/fzf-tab.plugin.zsh" ]] && \
    source "$custom_plugins/fzf-tab/fzf-tab.plugin.zsh"
fi

# Optimized aliases
if command -v eza >/dev/null 2>&1; then
  alias ll='eza -laF --group-directories-first'
  alias la='eza -A'
  alias l='eza -CF'
else
  alias ll='ls -laF'
  alias la='ls -A'
  alias l='ls -CF'
fi

# Application aliases
alias snowsql='/Applications/SnowSQL.app/Contents/MacOS/snowsql'

# Source additional configurations
[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases
[[ -f ~/.zsh_functions ]] && source ~/.zsh_functions

# Conditional prompt initialization (choose one)
if command -v starship >/dev/null 2>&1 && [[ -n "$STARSHIP_CONFIG" ]]; then
  # Starship prompt (feature-rich but slower)
  eval "$(starship init zsh)"
else
  # Fallback to Oh My Zsh theme (faster)
  # Theme already loaded by Oh My Zsh
fi

# Conditional tool initialization
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# SDKMAN (lazy loaded - use 'sdk' command to activate)
export SDKMAN_DIR="$HOME/.sdkman"
