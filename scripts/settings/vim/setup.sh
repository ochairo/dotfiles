#!/bin/bash -eu

if ! brew list --formula | grep -q "vim"; then
  brew install vim
fi

rm -dfr $HOME/.vim
mkdir -p $HOME/.vim
git clone https://github.com/catppuccin/vim.git $REPO_DIR/vim/catppuccin
mv $REPO_DIR/vim/catppuccin/colors $HOME/.vim/colors
rm -dfr $REPO_DIR/vim

ln -nfs $REPO_DIR/scripts/settings/vim/.vimrc $HOME/.vimrc

exit 0
