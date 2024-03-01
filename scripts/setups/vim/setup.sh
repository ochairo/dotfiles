#!/bin/bash -eu

if ! brew list --formula | grep -q "vim"; then
  brew install vim
fi

rm -dfr $HOME/.vim
mkdir -p $HOME/.vim
git clone https://github.com/catppuccin/vim.git $PATH_ROOT/vim/catppuccin
mv $PATH_ROOT/vim/catppuccin/colors $HOME/.vim/colors
rm -dfr $PATH_ROOT/vim

ln -nfs $PATH_SETUPS/vim/.vimrc $HOME/.vimrc

exit 0
