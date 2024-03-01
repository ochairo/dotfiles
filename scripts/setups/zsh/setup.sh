#!/bin/bash -eu

brew install zsh

brew install zsh-autosuggestions
brew install zsh-syntax-highlighting
brew install zsh-completions
brew install powerlevel10k

chmod go-w '/opt/homebrew/share'
chmod -R go-w '/opt/homebrew/share/zsh'

ln -nfs $PATH_SETUPS/zsh/.zshrc $HOME
ln -nfs $PATH_SETUPS/zsh/.zshenv $HOME
ln -nfs $PATH_SETUPS/zsh/.zlogin $HOME
ln -nfs $PATH_SETUPS/zsh/.zlogout $HOME
ln -nfs $PATH_SETUPS/zsh/.p10k.zsh $HOME

exit 0
