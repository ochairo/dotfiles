#!/bin/bash -eu

question="Do you want to setup Fonts?"
responseRef="selectedValue"
option1="Yes"
option2="No"
handle_question "$question" "$responseRef" "$option1" "$option2"

echo "> Your selection: $selectedValue"
case "$selectedValue" in
"$option1")
  if ! brew tap | grep -q "homebrew/cask-fonts"; then
    brew tap homebrew/cask-fonts
  fi

  if ! brew list --cask | grep -q "font-meslo-lg-nerd-font"; then
    brew install --cask font-meslo-lg-nerd-font
  fi
  ;;
"$option2") ;;
esac
