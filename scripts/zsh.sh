#!/bin/zsh -eu

brew install zsh

brew install zsh-autosuggestions
brew install zsh-syntax-highlighting
brew install zsh-completions

brew install powerlevel10k

# Avoid warnings when attempting to load completions
chmod go-w '/opt/homebrew/share'
chmod -R go-w '/opt/homebrew/share/zsh'

exit 0
