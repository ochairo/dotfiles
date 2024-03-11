#!/bin/bash -eu

question="Do you want to setup Flutter?"
responseRef="selectedValue"
option1="Yes"
option2="No"
handle_question "$question" "$responseRef" "$option1" "$option2"

echo "> Your selection: $selectedValue"
case "$selectedValue" in
"$option1")
  sudo softwareupdate --install-rosetta --agree-to-license

  if ! brew tap | grep -q "leoafarias/fvm"; then
    brew tap leoafarias/fvm
  fi

  if ! brew list --formula | grep -q "fvm"; then
    brew install fvm
    fvm install stable
    fvm global stable
  fi

  if ! brew list --formula | grep -q "fastlane"; then
    brew install fastlane
  fi

  if ! brew list --formula | grep -q "lefthook"; then
    brew install lefthook
  fi

  dart pub global activate flutter_gen
  ;;
"$option2") ;;
esac
