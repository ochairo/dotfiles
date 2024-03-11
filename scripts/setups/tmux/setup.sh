#!/bin/bash -eu

question="Do you want to setup Tmux?"
responseRef="selectedValue"
option1="Yes"
option2="No"
handle_question "$question" "$responseRef" "$option1" "$option2"

echo "> Your selection: $selectedValue"
case "$selectedValue" in
"$option1")
  if ! brew list --formula | grep -q "tmux"; then
    brew install tmux
  fi

  if ! brew list --formula | grep -q "tpm"; then
    brew install tpm
  fi

  rm $HOME/.tmux.conf
  ln -nfs $PATH_SETUPS/tmux/.tmux.conf $HOME/.tmux.conf
  ;;
"$option2") ;;
esac
