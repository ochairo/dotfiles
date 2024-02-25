#!/bin/zsh -eu

sudo softwareupdate --install-rosetta --agree-to-license

brew tap leoafarias/fvm
brew install fvm

fvm install stable
fvm global stable

brew install fastlane

brew install lefthook

dart pub global activate flutter_gen

exit 0
