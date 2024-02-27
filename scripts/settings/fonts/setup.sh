#!/bin/bash -eu

if ! brew tap | grep -q "homebrew/cask-fonts"; then
  brew tap homebrew/cask-fonts
fi

if ! brew list --cask | grep -q "font-meslo-lg-nerd-font"; then
  brew install --cask font-meslo-lg-nerd-font
fi

exit 0
