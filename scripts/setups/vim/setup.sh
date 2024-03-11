#!/bin/bash -eu

question="Do you want to setup Vim?"
responseRef="selectedValue"
option1="Yes"
option2="No"
handle_question "$question" "$responseRef" "$option1" "$option2"

echo "> Your selection: $selectedValue"
case "$selectedValue" in
"$option1")
  if ! brew list --formula | grep -q "vim"; then
    brew install vim
  fi

  rm -dfr $HOME/.vim
  mkdir -p $HOME/.vim
  git clone https://github.com/catppuccin/vim.git $PATH_ROOT/vim/catppuccin
  mv $PATH_ROOT/vim/catppuccin/colors $HOME/.vim/colors
  rm -dfr $PATH_ROOT/vim

  ln -nfs $PATH_SETUPS/vim/.vimrc $HOME/.vimrc
  ;;
"$option2") ;;
esac
