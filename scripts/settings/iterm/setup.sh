#!/bin/bash -eu

if ! brew list --cask | grep -q "iterm2"; then
  brew install --cask iterm2
fi

rm -dfr $HOME/.config/iterm2
mkdir -p $HOME/.config/iterm2/catppuccin
git clone https://github.com/catppuccin/iterm.git $REPO_DIR/iterm/catppuccin
mv $REPO_DIR/iterm/catppuccin/colors $HOME/.config/iterm2/catppuccin/colors
rm -dfr $REPO_DIR/iterm

exit 0
