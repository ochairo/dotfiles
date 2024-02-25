#!/bin/zsh -eu

echo "git.sh"

brew install git

brew install lazygit

cp -i $REPO_DIR/dotfiles/config/.gitconfig $HOME

exit 0
