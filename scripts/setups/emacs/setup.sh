#!/bin/bash -eu

question="Do you want to setup Emacs GUI?"
responseRef="selectedValue"
option1="Yes"
option2="No"
handle_question "$question" "$responseRef" "$option1" "$option2"

echo "> Your selection: $selectedValue"
case "$selectedValue" in
"$option1")
  if ! brew list --formula | grep -q "emacs"; then
    brew install --cask emacs

    git clone --depth 1 https://github.com/doomemacs/doomemacs $HOME/.config/emacs
    $HOME/.config/emacs/bin/doom install
    $HOME/.config/emacs/bin/doom upgrade
    $HOME/.config/emacs/bin/doom sync
  fi
  ;;
"$option2") ;;
esac
