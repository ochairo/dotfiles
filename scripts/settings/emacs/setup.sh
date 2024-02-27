#!/bin/bash -eu

if ! brew list --formula | grep -q "emacs"; then
  brew install emacs
  brew install emacs-dracula

  git clone --depth 1 https://github.com/doomemacs/doomemacs $HOME/.config/emacs
  $HOME/.config/emacs/bin/doom install
fi

exit 0
