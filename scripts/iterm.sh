#!/bin/zsh -eu

git clone https://github.com/catppuccin/iterm.git $REPO_DIR/dotfiles/config/iterm/colors/catppuccin

mkdir -p $HOME/.config/iterm2/catppuccin/colors
ln -nfs $REPO_DIR/dotfiles/config/iterm/colors/catppuccin/colors/* $HOME/.config/iterm2/catppuccin/colors

exit 0
