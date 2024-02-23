#!/bin/zsh -eu

echo "git.sh"

brew install lazygit

ln -nfs $REPO_DIR/dotfiles/config/.gitconfig $HOME

exit 0
