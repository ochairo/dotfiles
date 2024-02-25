#!/bin/zsh -eu

brew install git

brew install lazygit

cp -i $REPO_DIR/dotfiles/config/.gitconfig $HOME

exit 0
