skip_global_compinit=1

# -------------------- Language ------------------------------------------------
export LANG=en_US.UTF-8

# -------------------- Zsh -----------------------------------------------------
export HISTFILE=$HOME/.zsh/.zsh_history
export HISTSIZE=100000
export SAVEHIST=100000

# -------------------- Homebrew ------------------------------------------------
export BREW_ROOT=/opt/homebrew
export PATH=$BREW_ROOT/bin:$PATH

# -------------------- Emacs ---------------------------------------------------
export EMACS_ROOT=$HOME/.emacs.d
export PATH=$EMACS_ROOT/bin:$PATH

# -------------------- Ruby version(rbenv) -------------------------------------
export RBENV_ROOT=$HOME/.rbenv
export PATH=$RBENV_ROOT/bin:$PATH

# -------------------- Python version(rbenv) -----------------------------------
export PYENV_ROOT=$HOME/.pyenv
export PATH=$PYENV_ROOT/bin:$PATH

# -------------------- Flutter -------------------------------------------------
export PATH=$PATH:$HOME/fvm/default/bin
