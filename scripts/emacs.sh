#!/bin/zsh -eu

echo "emacs.sh"

brew install emacs
git clone --depth 1 https://github.com/doomemacs/doomemacs $HOME/.config/emacs

$HOME/.config/emacs/bin/doom install

exit 0
