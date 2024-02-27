#!/bin/bash -eu

# Confirm with the user if they want to continue ------------------------------
valid_choice=false
while [ "$valid_choice" == false ]; do
  read -p "${BLUE}Do you want to setup Neovim? (y/n): ${NC}" choice
  case "$choice" in
  y | Y)
    echo "Yes"
    echo ""
    valid_choice=true
    if ! brew list --formula | grep -q "neovim"; then
      brew install neovim
    fi

    if command -v python &>/dev/null; then
      python -m pip install --user --upgrade pynvim
    fi

    if [ ! -d $HOME/.config/nvim ]; then
      git clone https://github.com/LazyVim/starter.git $HOME/.config/nvim
      rm -rf $HOME/.config/nvim/.git
    fi

    rm -dfr $HOME/.config/nvim/lua/plugins
    mkdir -p $HOME/.config/nvim/lua/plugins
    ln -nfs $REPO_DIR/scripts/settings/nvim/plugins/* $HOME/.config/nvim/lua/plugins
    ;;
  n | N)
    valid_choice=true
    ;;
  *)
    echo "${RED}Invalid choice. Please enter 'y' or 'n'${NC}"
    echo ""
    ;;
  esac
done

exit 0
