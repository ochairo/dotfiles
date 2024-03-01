#!/bin/bash -eu

if ! brew list --cask | grep -q "iterm2"; then
  brew install --cask iterm2
fi

rm -dfr $HOME/.config/iterm2
mkdir -p $HOME/.config/iterm2/catppuccin
git clone https://github.com/catppuccin/iterm.git $PATH_ROOT/iterm/catppuccin
mv $PATH_ROOT/iterm/catppuccin/colors $HOME/.config/iterm2/catppuccin/colors
rm -dfr $PATH_ROOT/iterm

exit 0
