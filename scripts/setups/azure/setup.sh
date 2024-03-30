#!/bin/bash -eu

question="Do you want to setup Azure CLI?"
responseRef="selectedValue"
option1="Yes"
option2="No"
handle_question "$question" "$responseRef" "$option1" "$option2"

echo "> Your selection: $selectedValue"
case "$selectedValue" in
"$option1")
  if ! brew list --formula | grep -q "az"; then
    brew install azure-cli
  fi
  ;;
"$option2") ;;
esac
