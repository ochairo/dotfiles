#!/bin/zsh -eux

clear

RED='\033[1;91m'
BLUE='\033[1;94m'
GREEN='\033[1;92m'
GRAY='\033[1;30m'
NC='\033[0m'
PDW=$(pwd)

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

export REPO_DIR=$PDW

echo "${BLUE}"
echo "0000000000000000000000000000000000000000000000000000000000000000000000000"
echo ""
echo "                   Welcome to ochairo's basic setup!                     "
echo ""
echo "0000000000000000000000000000000000000000000000000000000000000000000000000"
echo "${NC}"
echo "Hello, $USER!!"
echo ""
echo "This is a basic development environment setup for clean install."
echo "Feel free to use it as a reference for your own setup."
echo "※ you can find the source code at ${GRAY}https://github.com/ochairo/dotfiles${NC}"
echo ""

if [ `uname` != "Darwin" ]; then
    error_handler 1 "This is only for macOS"
fi

valid_choice=false
while [ "$valid_choice" == false ]; do
    echo ${GREEN}
    read -p "Do you want to continue? (y/n):" choice
    echo ${NC}

    case "$choice" in
        y|Y) 
            echo "Yes"
            valid_choice=true
            ;;
        n|N)
            echo "No"
            echo "${BLUE}"
            echo "_________________________________________________________________________"
            echo "                          PROCESS CANCELED!"
            echo "${NC}"
            exit 1
            ;;
        *)
            echo " ${RED}Invalid choice. Please enter 'y' or 'n'${NC}"
            ;;
    esac
done

echo ""
echo ""
echo "${GREEN}                          . ... Setting ... .${NC}"

brew_output=$(./scripts/brew.sh 2>&1)
brew_exit_status=$?
if [ $brew_exit_status -ne 0 ]; then
    error_handler $brew_exit_status "$brew_output"
fi

essentials_output=$(./scripts/essentials.sh 2>&1)
essentials_output_status=$?
if [ $essentials_output_status -ne 0 ]; then
    error_handler $essentials_output_status "$essentials_output"
fi

zsh_output=$(./scripts/zsh.sh 2>&1)
zsh_output_status=$?
if [ $zsh_output_status -ne 0 ]; then
    error_handler $zsh_output_status "$zsh_output"
fi

tmux_output=$(./scripts/tmux.sh 2>&1)
tmux_output_status=$?
if [ $tmux_output_status -ne 0 ]; then
    error_handler $tmux_output_status "$tmux_output"
fi

fonts_output=$(./scripts/fonts.sh 2>&1)
fonts_output_status=$?
if [ $fonts_output_status -ne 0 ]; then
    error_handler $fonts_output_status "$fonts_output"
fi

git_output=$(./scripts/git.sh 2>&1)
git_output_status=$?
if [ $git_output_status -ne 0 ]; then
    error_handler $git_output_status "$git_output"
fi

vim_output=$(./scripts/vim.sh 2>&1)
vim_output_status=$?
if [ $git_output_status -ne 0 ]; then
    error_handler $vim_output_status "$vim_output"
fi

nvim_output=$(./scripts/nvim.sh 2>&1)
nvim_output_status=$?
if [ $nvim_output_status -ne 0 ]; then
    error_handler $nvim_output_status "$nvim_output"
fi

iterm_output=$(./scripts/iterm.sh 2>&1)
iterm_output_status=$?
if [ $iterm_output_status -ne 0 ]; then
    error_handler $iterm_output_status "$iterm_output"
fi

emacs_output=$(./scripts/emacs.sh 2>&1)
emacs_output_status=$?
if [ $emacs_output_status -ne 0 ]; then
    error_handler $emacs_output_status "$emacs_output"
fi

vscode_output=$(./scripts/vscode.sh 2>&1)
vscode_output_status=$?
if [ $vscode_output_status -ne 0 ]; then
    error_handler $vscode_output_status "$vscode_output"
fi

flutter_output=$(./scripts/flutter.sh 2>&1)
flutter_output_status=$?
if [ $flutter_output_status -ne 0 ]; then
    error_handler $flutter_output_status "$flutter_output"
fi

echo ${BLUE}
echo "0000000000000000000000000000000000000000000000000000000000000000000000000"
echo ""
echo "               🚀 CONGRATULATIONS! SETUP IS COMPLETE! 🚀" 
echo ""
echo "0000000000000000000000000000000000000000000000000000000000000000000000000"
echo "       Your environment is ready for your personal configurations!"
echo ${NC}

exit 0
