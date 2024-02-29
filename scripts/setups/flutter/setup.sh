#!/bin/bash -eu

# sudo softwareupdate --install-rosetta --agree-to-license

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

exit 0
