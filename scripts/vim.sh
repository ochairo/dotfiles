#!/bin/zsh -eu

echo "vim.sh"

brew install vim

git clone https://github.com/catppuccin/vim.git $REPO_DIR/dotfiles/config/vim/colorschemes/catppuccin

mkdir -p $HOME/.vim/colors
ln -nfs $REPO_DIR/dotfiles/config/vim/colorschemes/catppuccin/colors/* $HOME/.vim/colors

ln -nfs $REPO_DIR/dotfiles/config/.vimrc $HOME/.vimrc

exit 0
