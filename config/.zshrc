# -------------------- History ------------------------------------------------
setopt append_history         # Allow multiple sessions to append to one Zsh command history.
setopt extended_history       # Show timestamp in history.
setopt hist_expire_dups_first # Expire A duplicate event first when trimming history.
setopt hist_find_no_dups      # Do not display a previously found event.
setopt hist_ignore_all_dups   # Remove older duplicate entries from history.
setopt hist_ignore_dups       # Do not record an event that was just recorded again.
setopt hist_ignore_space      # Do not record an Event Starting With A Space.
setopt hist_reduce_blanks     # Remove superfluous blanks from history items.
setopt hist_save_no_dups      # Do not write a duplicate event to the history file.
setopt hist_verify            # Do not execute immediately upon history expansion.
setopt inc_append_history     # Write to the history file immediately, not when the shell exits.
setopt share_history          # Share history between different instances of the shell.
setopt no_beep                # Don't beep on error.

# -------------------- Powerlevel10k -------------------------------------------
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# -------------------- Autosuggestions ----------------------------------------
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# -------------------- Highlighting -------------------------------------------
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# -------------------- Completions ---------------------------------------------
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit
  compinit
fi

# -------------------- Aliases ------------------------------------------------
alias la="ls -a"
alias lgit="lazygit"
alias ll="ls -lA"
alias ls="ls -G"

# -------------------- Directory environment manager ---------------------------------------
eval "$(direnv hook zsh)"

# -------------------- Node version(fnm) ---------------------------------------
eval "$(fnm env --use-on-cd)"

# -------------------- Ruby version(rbenv) -------------------------------------
eval "$(rbenv init -)"

# -------------------- Python version(rbenv) -----------------------------------
eval "$(pyenv init -)"
