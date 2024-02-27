#!/bin/bash -eu

if ! brew list --formula | grep -q "tmux"; then
  brew install tmux
fi

if ! brew list --formula | grep -q "tpm"; then
  brew install tpm
fi

rm $HOME/.tmux.conf
ln -nfs $REPO_DIR/scripts/settings/tmux/.tmux.conf $HOME/.tmux.conf

exit 0
