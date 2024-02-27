#!/bin/bash -eu

brew install zsh

brew install zsh-autosuggestions
brew install zsh-syntax-highlighting
brew install zsh-completions
brew install powerlevel10k

chmod go-w '/opt/homebrew/share'
chmod -R go-w '/opt/homebrew/share/zsh'

ln -nfs $REPO_DIR/scripts/settings/zsh/.zshrc $HOME
ln -nfs $REPO_DIR/scripts/settings/zsh/.zshenv $HOME
ln -nfs $REPO_DIR/scripts/settings/zsh/.zlogin $HOME
ln -nfs $REPO_DIR/scripts/settings/zsh/.zlogout $HOME
ln -nfs $REPO_DIR/scripts/settings/zsh/.p10k.zsh $HOME

exit 0
