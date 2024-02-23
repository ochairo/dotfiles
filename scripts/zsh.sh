#!/bin/zsh -eu

echo "zsh.sh"

brew install zsh
brew install powerlevel10k

git clone https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.zsh/plugins/zsh-users/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh/plugins/zsh-users/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions.git $HOME/.zsh/plugins/zsh-users/zsh-completions

ln -nfs $REPO_DIR/dotfiles/config/.zshenv $HOME/.zshenv
ln -nfs $REPO_DIR/dotfiles/config/.zshrc $HOME/.zshrc
ln -nfs $REPO_DIR/dotfiles/config/.zlogin $HOME/.zlogin
ln -nfs $REPO_DIR/dotfiles/config/.zlogout $HOME/.zlogout

exit 0
