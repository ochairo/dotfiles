#!/bin/bash

# Strict mode: exit on error, undefined vars, pipe failures
set -euo pipefail

# Script metadata
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="$(basename "$0")"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Cleanup on exit
cleanup() {
    local exit_code=$?
    if [ -n "${TEMP_ZIP:-}" ] && [ -f "$TEMP_ZIP" ]; then
        rm -f "$TEMP_ZIP"
    fi
    if [ -n "${TEMP_DIR:-}" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
    return $exit_code
}
trap cleanup EXIT

# Configuration
DOTFILES_DIR="${HOME}/.dotfiles"
DOTFILES_REPO="https://github.com/ochairo/dotfiles"
DOTFILES_BRANCH="main"

# Check for required commands
check_requirements() {
    local required_cmds=("curl" "unzip" "find")
    for cmd in "${required_cmds[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo -e "${RED}✗ Required command '$cmd' not found${NC}"
            exit 1
        fi
    done
}

# Print usage
usage() {
    cat << EOF
${BLUE}Usage: $SCRIPT_NAME [OPTIONS]${NC}

${BLUE}Options:${NC}
  --dir DIR       Installation directory (default: ~/.dotfiles)
  --repo URL      Repository URL (default: https://github.com/ochairo/dotfiles)
  --branch BRANCH Git branch (default: main)
  --help          Show this help message
  --version       Show version

${BLUE}Example:${NC}
  curl -sSL https://raw.githubusercontent.com/ochairo/dotfiles/main/scripts/install.sh | bash

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dir)
            DOTFILES_DIR="$2"
            shift 2
            ;;
        --repo)
            DOTFILES_REPO="$2"
            shift 2
            ;;
        --branch)
            DOTFILES_BRANCH="$2"
            shift 2
            ;;
        --help)
            usage
            exit 0
            ;;
        --version)
            echo "$SCRIPT_VERSION"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            exit 1
            ;;
    esac
done

# Validate inputs
if [[ ! "$DOTFILES_DIR" =~ ^/ ]] && [[ ! "$DOTFILES_DIR" =~ ^\~ ]]; then
    echo -e "${RED}✗ Directory path must be absolute or start with ~${NC}"
    exit 1
fi

# Expand ~ to home directory
DOTFILES_DIR="${DOTFILES_DIR/#\~/$HOME}"

# Expand ~ to home directory
DOTFILES_DIR="${DOTFILES_DIR/#\~/$HOME}"

# Main installation flow
main() {
    echo -e "${BLUE}🪄 Wand Dotfiles Installer v${SCRIPT_VERSION}${NC}"
    echo ""

    # Check requirements first
    check_requirements

    # Step 1: Check if wand is installed
    echo -e "${YELLOW}[1/3]${NC} Checking for Wand..."
    if ! command -v wand &> /dev/null; then
        echo -e "${YELLOW}Installing Wand...${NC}"
        if ! curl -sSL https://raw.githubusercontent.com/ochairo/wand/main/scripts/install.sh | bash; then
            echo -e "${RED}✗ Wand installation failed${NC}"
            echo "Please manually install from: https://github.com/ochairo/wand"
            return 1
        fi

        # Try to source shell config to make wand available
        if [ -f "$HOME/.zshrc" ]; then
            source "$HOME/.zshrc" 2>/dev/null || true
        elif [ -f "$HOME/.bashrc" ]; then
            source "$HOME/.bashrc" 2>/dev/null || true
        fi

        # Verify wand is now available
        if ! command -v wand &> /dev/null; then
            echo -e "${RED}✗ Wand installation failed${NC}"
            echo "Please manually install from: https://github.com/ochairo/wand"
            return 1
        fi
    fi
    echo -e "${GREEN}✓ Wand is installed${NC}"
    echo ""

    # Step 2: Download dotfiles
    echo -e "${YELLOW}[2/3]${NC} Downloading dotfiles..."
    if [ -d "$DOTFILES_DIR" ]; then
        echo -e "${YELLOW}⚠ Dotfiles already exist at $DOTFILES_DIR${NC}"
        echo "   Skipping download. To reinstall, remove: rm -rf $DOTFILES_DIR"
    else
        TEMP_ZIP=$(mktemp) || { echo -e "${RED}✗ Failed to create temp file${NC}"; return 1; }
        TEMP_DIR=$(mktemp -d) || { echo -e "${RED}✗ Failed to create temp directory${NC}"; return 1; }

        echo "Downloading from: ${DOTFILES_REPO}/archive/refs/heads/${DOTFILES_BRANCH}.zip"

        if ! curl -fsSL "${DOTFILES_REPO}/archive/refs/heads/${DOTFILES_BRANCH}.zip" -o "$TEMP_ZIP"; then
            echo -e "${RED}✗ Failed to download dotfiles${NC}"
            return 1
        fi

        if [ ! -s "$TEMP_ZIP" ]; then
            echo -e "${RED}✗ Downloaded file is empty${NC}"
            return 1
        fi

        if ! unzip -q "$TEMP_ZIP" -d "$TEMP_DIR"; then
            echo -e "${RED}✗ Failed to extract dotfiles${NC}"
            return 1
        fi

        # Find extracted directory (handles different repo names)
        EXTRACTED_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d ! -name "." ! -name ".." | head -1)

        if [ -z "$EXTRACTED_DIR" ] || [ ! -d "$EXTRACTED_DIR" ]; then
            echo -e "${RED}✗ Could not find extracted dotfiles directory${NC}"
            return 1
        fi

        # Create parent directory if needed
        if ! mkdir -p "$(dirname "$DOTFILES_DIR")"; then
            echo -e "${RED}✗ Failed to create directory: $(dirname "$DOTFILES_DIR")${NC}"
            return 1
        fi

        if ! mv "$EXTRACTED_DIR" "$DOTFILES_DIR"; then
            echo -e "${RED}✗ Failed to move dotfiles to $DOTFILES_DIR${NC}"
            return 1
        fi

        echo -e "${GREEN}✓ Dotfiles downloaded to $DOTFILES_DIR${NC}"
    fi
    echo ""

    # Step 3: Install with wand
    echo -e "${YELLOW}[3/3]${NC} Installing tools and creating symlinks..."

    if [ ! -d "$DOTFILES_DIR" ]; then
        echo -e "${RED}✗ Dotfiles directory not found: $DOTFILES_DIR${NC}"
        return 1
    fi

    if [ ! -f "$DOTFILES_DIR/wandfile.yaml" ]; then
        echo -e "${RED}✗ wandfile.yaml not found in $DOTFILES_DIR${NC}"
        return 1
    fi

    if ! cd "$DOTFILES_DIR"; then
        echo -e "${RED}✗ Failed to change directory to $DOTFILES_DIR${NC}"
        return 1
    fi

    if ! wand wandfile install; then
        echo -e "${RED}✗ Installation failed${NC}"
        return 1
    fi

    echo -e "${GREEN}✓ Installation complete${NC}"
    echo ""
    echo -e "${GREEN}✨ All done!${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Restart your shell or run: source ~/.zshrc"
    echo "  2. Update git config: git config --global user.email 'you@example.com'"
    echo "  3. Customize: fork and edit configs in $DOTFILES_DIR"
    echo ""
    echo "For more info, visit: https://github.com/ochairo/dotfiles"
    echo ""
}

# Run main function
main "$@"
