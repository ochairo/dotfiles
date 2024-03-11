#!/bin/bash -eu

question="Do you want to setup iTerm2?"
responseRef="selectedValue"
option1="Yes"
option2="No"
handle_question "$question" "$responseRef" "$option1" "$option2"

echo "> Your selection: $selectedValue"
case "$selectedValue" in
"$option1")
  if ! brew list --cask | grep -q "iterm2"; then
    brew install --cask iterm2
  fi

  rm -dfr $HOME/.config/iterm2
  mkdir -p $HOME/.config/iterm2/catppuccin
  git clone https://github.com/catppuccin/iterm.git $PATH_ROOT/iterm/catppuccin
  mv $PATH_ROOT/iterm/catppuccin/colors $HOME/.config/iterm2/catppuccin/colors
  rm -dfr $PATH_ROOT/iterm
  ;;
"$option2") ;;
esac
