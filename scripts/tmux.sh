#!/bin/zsh -eu

brew install tmux

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

ln -nfs $REPO_DIR/dotfiles/config/tmux $HOME/

exit 0
