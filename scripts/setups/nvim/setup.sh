#!/bin/bash -eu

yes="Yes"
no="No"
handle_question response "Do you want to setup Emacs?" "$yes" "$no"

echo "> Your selection: $response"
case "$response" in
"$yes")
  if ! brew list --formula | grep -q "neovim"; then
    brew install neovim
  fi

  if command -v python &>/dev/null; then
    python -m pip install --user --upgrade pynvim
  fi

  if [ ! -d $HOME/.config/nvim ]; then
    git clone https://github.com/LazyVim/starter.git $HOME/.config/nvim
    rm -rf $HOME/.config/nvim/.git
  fi

  rm -dfr $HOME/.config/nvim/lua/plugins
  mkdir -p $HOME/.config/nvim/lua/plugins
  ln -nfs $PATH_SETUPS/nvim/plugins/* $HOME/.config/nvim/lua/plugins
  ;;
"$no") ;;
esac

exit 0
