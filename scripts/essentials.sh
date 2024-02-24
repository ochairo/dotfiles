#!/bin/zsh -eu

echo "essentails.sh"

# -------------------- Basic commands ------------------------------------------
brew install bash
brew install coreutils
brew install fd
brew install findutils
brew install gawk
brew install gnu-sed
brew install gnu-tar
brew install grep
brew install gzip
brew install less
brew install make
brew install openssh
brew install ripgrep
brew install rsync
brew install tree
brew install unzip
brew install wget

# -------------------- Environment manage ----------------------------------------
brew install direnv

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
brew install --cask hhkb

# -------------------- Browsers ------------------------------------------------
brew install --cask brave-browser
brew install --cask firefox
brew install --cask google-chrome
brew install --cask microsoft-edge

# -------------------- Chats ---------------------------------------------------
brew install --cask discord
brew install --cask microsoft-teams
brew install --cask slack

# -------------------- Screenshot ----------------------------------------------
brew install --cask shottr

exit 0
