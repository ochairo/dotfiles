#!/bin/zsh -eux

echo "setup.sh"

# TODO: Create an interactive script to setup.

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

error_handler() {
    local exit_code=$1
    local error_message=$2
    echo "${RED}"
		echo "- ERROR -------------------------------------------------"
    echo "Error Number: ${exit_code}"
		echo "${error_message}"
    echo "---------------------------------------------------------"
		echo "${NC}"
    exit $exit_code
}

if [ -n "$REPO_DIR" ]; then
    echo "REPO_DIR is set to $REPO_DIR."
else
    echo "${YELLOW}Setting REPO_DIR to default value: $HOME.${NC}"
    export REPO_DIR=$HOME
fi

echo "brew.sh"
brew_output=$(./scripts/brew.sh 2>&1)
brew_exit_status=$?
if [ $brew_exit_status -ne 0 ]; then
    error_handler $brew_exit_status "$brew_output"
fi

echo "essentials.sh"
essentials_output=$(./scripts/essentials.sh 2>&1)
essentials_output_status=$?
if [ $essentials_output_status -ne 0 ]; then
    error_handler $essentials_output_status "$essentials_output"
fi

echo "zsh.sh"
zsh_output=$(./scripts/zsh.sh 2>&1)
zsh_output_status=$?
if [ $zsh_output_status -ne 0 ]; then
    error_handler $zsh_output_status "$zsh_output"
fi

echo "tmux.sh"
tmux_output=$(./scripts/tmux.sh 2>&1)
tmux_output_status=$?
if [ $tmux_output_status -ne 0 ]; then
    error_handler $tmux_output_status "$tmux_output"
fi

echo "fonts.sh"
fonts_output=$(./scripts/fonts.sh 2>&1)
fonts_output_status=$?
if [ $fonts_output_status -ne 0 ]; then
    error_handler $fonts_output_status "$fonts_output"
fi

echo "git.sh"
git_output=$(./scripts/git.sh 2>&1)
git_output_status=$?
if [ $git_output_status -ne 0 ]; then
    error_handler $git_output_status "$git_output"
fi

echo "vim.sh"
vim_output=$(./scripts/vim.sh 2>&1)
vim_output_status=$?
if [ $git_output_status -ne 0 ]; then
    error_handler $vim_output_status "$vim_output"
fi

echo "nvim.sh"
nvim_output=$(./scripts/nvim.sh 2>&1)
nvim_output_status=$?
if [ $nvim_output_status -ne 0 ]; then
    error_handler $nvim_output_status "$nvim_output"
fi

echo "iterm.sh"
iterm_output=$(./scripts/iterm.sh 2>&1)
iterm_output_status=$?
if [ $iterm_output_status -ne 0 ]; then
    error_handler $iterm_output_status "$iterm_output"
fi

echo "emacs.sh"
emacs_output=$(./scripts/emacs.sh 2>&1)
emacs_output_status=$?
if [ $emacs_output_status -ne 0 ]; then
    error_handler $emacs_output_status "$emacs_output"
fi

echo "vscode.sh"
vscode_output=$(./scripts/vscode.sh 2>&1)
vscode_output_status=$?
if [ $vscode_output_status -ne 0 ]; then
    error_handler $vscode_output_status "$vscode_output"
fi

echo "flutter.sh"
flutter_output=$(./scripts/flutter.sh 2>&1)
flutter_output_status=$?
if [ $flutter_output_status -ne 0 ]; then
    error_handler $flutter_output_status "$flutter_output"
fi

echo ${GREEN}
echo "    ********************************************************************"
echo "    *                                                                  *"
echo "    *                 COMPLETED SETUP SUCCESSFULLY!                    *"
echo "    *                                                                  *"
echo "    ********************************************************************"
echo "    *                                                                  *"
echo "    *    Configurations                                                *"
echo "    *                                                                  *"
echo "    *       - Terminal                                                 *"
echo "    *         - Open or re-open your terminal.                         *"
echo "    *         - Follow the instructions displayed in the terminal.     *"
echo "    *                                                                  *"
echo "    *                                                                  *"
echo "    ********************************************************************"
echo ${NC}

exit 0
