#!/bin/zsh -eu

echo "essentails.sh"

# -------------------- Basic commands ------------------------------------------
brew install tree
brew install wget
brew install lf
brew install fd
brew install ripgrep

# -------------------- Version managers ----------------------------------------
brew install fnm
fnm install --lts

brew install pyenv
pyenv install 3.12.0
pyenv global 3.12.0

brew install rbenv
rbenv install 3.3.0
rbenv global 3.3.0

brew install tpm
brew install cocoapods

# -------------------- Terminal ------------------------------------------------
brew install --cask iterm2

# -------------------- IME -----------------------------------------------------
brew install --cask google-japanese-ime

# -------------------- Keybindings ---------------------------------------------
brew install --cask karabiner-elements
brew install --cask hhkb

# -------------------- Browsers ------------------------------------------------
brew install --cask brave-browser
brew install --cask google-chrome
brew install --cask firefox
brew install --cask microsoft-edge

# -------------------- Chats ---------------------------------------------------
brew install --cask microsoft-teams
brew install --cask discord
brew install --cask slack

# -------------------- Screenshot ----------------------------------------------
brew install --cask shottr

exit 0
