#!/bin/bash -eu

# -------------------- Basic commands ------------------------------------------
brew install bash
brew install zsh
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
if ! brew list --formula | grep -q "direnv"; then
  brew install direnv
fi

# -------------------- Version managers ----------------------------------------
if ! brew list --formula | grep -q "fnm"; then
  brew install fnm
  fnm install --lts
fi

if ! brew list --formula | grep -q "pyenv"; then
  brew install pyenv
  pyenv install 3.12.0
  pyenv global 3.12.0
fi

if ! brew list --formula | grep -q "rbenv"; then
  brew install rbenv
  rbenv install 3.3.0
  rbenv global 3.3.0
fi

if ! brew list --formula | grep -q "tpm"; then
  brew install tpm
fi

if ! brew list --formula | grep -q "cocoapods"; then
  brew install cocoapods
fi

# -------------------- IME -----------------------------------------------------
if ! brew list --cask | grep -q "google-japanese-ime"; then
  brew install --cask google-japanese-ime
fi

# -------------------- Keybindings ---------------------------------------------
if ! brew list --cask | grep -q "hhkb"; then
  brew install --cask hhkb
fi

# -------------------- Browsers ------------------------------------------------
if ! brew list --cask | grep -q "brave-browser"; then
  brew install --cask brave-browser
fi
if ! brew list --cask | grep -q "firefox"; then
  brew install --cask firefox
fi
if ! brew list --cask | grep -q "google-chrome"; then
  brew install --cask google-chrome
fi
if ! brew list --cask | grep -q "microsoft-edge"; then
  brew install --cask microsoft-edge
fi

# -------------------- Chats ---------------------------------------------------
if ! brew list --cask | grep -q "discord"; then
  brew install --cask discord
fi
if ! brew list --cask | grep -q "microsoft-teams"; then
  brew install --cask microsoft-teams
fi
if ! brew list --cask | grep -q "slack"; then
  brew install --cask slack
fi

# --------------------- Virtualization ------------------------------------------
if ! brew list --formula | grep -q "qemu"; then
  brew install qemu
fi

exit 0
