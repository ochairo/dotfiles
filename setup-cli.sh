#!/bin/zsh -eux

# Clear the terminal ------------------------------------------------------------------------------
clear

# Set the color variables -------------------------------------------------------------------------
BLUE=$(tput setaf 4)
GRAY=$(tput setaf 8)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
NC=$(tput sgr0)
PDW=$(pwd)

# Set the environment variables -------------------------------------------------------------------
export REPO_DIR=$PDW

# Set the error handler function -------------------------------------------------------------------
handle_error() {
  local exit_code=$1
  local error_message=$2
  echo "${RED}"
  echo "────────────────────────────────── ERROR ───────────────────────────────────────"
  echo "Error Number: ${exit_code}"
  echo "${error_message}"
  echo "________________________________________________________________________________"
  echo "                              PROCESS CANCELED!"
  echo "${NC}"
  exit $exit_code
}

# Start the setup ----------------------------------------------------------------------------------
echo "${BLUE}"
echo "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
echo ""
echo "                     Welcome to ochairo's basic setup!"
echo ""
echo "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
echo "${NC}"
echo "Hello, $USER!!"
echo ""
echo "This is a basic development environment setup for clean install."
echo "Feel free to use it as a reference for your own setup."
echo "※ you can find the source code at ${GRAY}https://github.com/ochairo/dotfiles${NC}"
echo ""

# Check if the OS is macOS ------------------------------------------------------------------------
if [ $(uname) != "Darwin" ]; then
  error_handler 1 "This is only for macOS"
fi

# Ask the user if they want to continue -----------------------------------------------------------
valid_choice=false
while [ "$valid_choice" == false ]; do
  read -p "${GREEN}Do you want to continue? (y/n): ${NC}" choice
  case "$choice" in
  y | Y)
    echo "Yes"
    echo ""
    echo ""
    valid_choice=true
    ;;
  n | N)
    echo "No"
    echo "${BLUE}"
    echo "________________________________________________________________________________"
    echo "                              PROCESS CANCELED!"
    echo "${NC}"
    exit 1
    ;;
  *)
    echo "${RED}Invalid choice. Please enter 'y' or 'n'${NC}"
    echo ""
    ;;
  esac
done

# Start the setup ---------------------------------------------------------------------------------
echo "${GREEN}                            . ... Setting ... .${NC}"
echo ""

scripts=(
  "/scripts/brew.sh"
  "/scripts/essentials.sh"
  "/scripts/zsh.sh"
  "/scripts/tmux.sh"
  "/scripts/fonts.sh"
  "/scripts/git.sh"
  "/scripts/vim.sh"
  "/scripts/nvim.sh"
  "/scripts/iterm.sh"
  "/scripts/emacs.sh"
  "/scripts/vscode.sh"
  "/scripts/flutter.sh"
  "/scripts/cleanup.sh"
)

for script in "${scripts[@]}"; do
  echo ""
  echo "${GREEN}Running $script ...${NC}"
  echo ""

  # Execute the script
  ./$script

  # Check the exit status of the script
  if [ $? -ne 0 ]; then
    handle_error "Error running $script"
  fi
done

# Finish the setup --------------------------------------------------------------------------------
echo ${BLUE}
echo "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
echo ""
echo "                  🚀 CONGRATULATIONS! SETUP IS COMPLETE! 🚀"
echo ""
echo "00000000000000000000000000000000000000000000000000000000000000000000000000000000"
echo "           Your environment is ready for your personal configurations!"
echo ${NC}

exit 0
