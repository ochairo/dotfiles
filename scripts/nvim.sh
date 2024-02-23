#!/bin/zsh -eu

echo "nvim.sh"

brew install neovim

python -m pip install --user --upgrade pynvim

git clone https://github.com/LazyVim/starter.git $HOME/.config/nvim

rm -rf $HOME/.config/nvim/.git

ln -nfs $REPO_DIR/dotfiles/config/nvim/plugins/* $HOME/.config/nvim/lua/plugins

exit 0
