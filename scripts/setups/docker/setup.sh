#!/bin/bash -eu

question="Do you want to setup Docker?"
responseRef="selectedValue"
option1="Yes"
option2="No"
handle_question "$question" "$responseRef" "$option1" "$option2"

echo "> Your selection: $selectedValue"
case "$selectedValue" in
"$option1")
  if ! brew list --formula | grep -q "docker"; then
    brew install docker
  fi
  ;;
"$option2") ;;
esac
