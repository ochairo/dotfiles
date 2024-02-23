#!/bin/zsh -eu

echo "flutter.sh"

sudo softwareupdate --install-rosetta --agree-to-license

brew tap leoafarias/fvm
brew install fvm
fvm install stable
fvm global stable

# https://docs.flutter.dev/deployment/cd#fastlane
# https://docs.fastlane.tools/
brew install fastlane

# https://pub.dev/packages/flutter_gen
dart pub global activate flutter_gen

exit 0
