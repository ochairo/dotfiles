#!/bin/bash -eu

question="Do you want to setup ZSH?"
responseRef="selectedValue"
option1="Yes"
option2="No"
handle_question "$question" "$responseRef" "$option1" "$option2"

echo "> Your selection: $selectedValue"
case "$selectedValue" in
"$option1")
  brew install zsh

  brew install zsh-autosuggestions
  brew install zsh-syntax-highlighting
  brew install zsh-completions
  brew install powerlevel10k

  chmod go-w '/opt/homebrew/share'
  chmod -R go-w '/opt/homebrew/share/zsh'

  ln -nfs $PATH_SETUPS/zsh/.zshrc $HOME
  ln -nfs $PATH_SETUPS/zsh/.zshenv $HOME
  ln -nfs $PATH_SETUPS/zsh/.zlogin $HOME
  ln -nfs $PATH_SETUPS/zsh/.zlogout $HOME
  ln -nfs $PATH_SETUPS/zsh/.p10k.zsh $HOME
  ;;
"$option2") ;;
esac
