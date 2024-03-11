#!/bin/bash -eu

question="Do you want to setup Nvim?"
responseRef="selectedValue"
option1="Yes"
option2="No"
handle_question "$question" "$responseRef" "$option1" "$option2"

echo "> Your selection: $selectedValue"
case "$selectedValue" in
"$option1")
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
"$option2") ;;
esac
