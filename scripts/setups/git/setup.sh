#!/bin/bash -eux

if ! brew list --formula | grep -q "git"; then
  brew install git
fi

if ! brew list --formula | grep -q "lazygit"; then
  brew install lazygit
fi

if ! brew list --formula | grep -q "gh"; then
  brew install gh
fi

if ! brew list --formula | grep -q "gh"; then
  brew install gh
fi

if [ ! -d $HOME/.config/git ]; then
  mkdir -p $HOME/.config/git
  cp $PATH_SETUPS/git/config $HOME/.config/git/config
  cp $PATH_SETUPS/git/ignore $HOME/.config/git/ignore
fi

exit 0
