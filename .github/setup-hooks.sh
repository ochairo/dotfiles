#!/usr/bin/env bash
# Setup script to install Git hooks for the dotfiles project
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🪝 Setting up Git hooks for dotfiles project...${NC}"

# Check if we're in a git repository
if [ ! -d ".git" ]; then
	echo -e "${RED}❌ Not in a Git repository. Please run this from the project root.${NC}"
	exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# List of hooks to install
hooks=(
	"pre-commit"
	"commit-msg"
	"post-commit"
)

# Install each hook
for hook in "${hooks[@]}"; do
	source_file=".github/hooks/$hook"
	target_file=".git/hooks/$hook"

	if [ -f "$source_file" ]; then
		echo -e "${BLUE}📝 Installing $hook hook...${NC}"

		# Backup existing hook if it exists
		if [ -f "$target_file" ]; then
			echo -e "${YELLOW}⚠️  Backing up existing $hook hook to $target_file.backup${NC}"
			cp "$target_file" "$target_file.backup"
		fi

		# Copy and make executable
		cp "$source_file" "$target_file"
		chmod +x "$target_file"

		echo -e "${GREEN}✅ $hook hook installed${NC}"
	else
		echo -e "${RED}❌ Hook file $source_file not found${NC}"
	fi
done

echo ""
echo -e "${GREEN}🎉 Git hooks setup complete!${NC}"
echo ""
echo -e "${BLUE}📋 Installed hooks:${NC}"
echo -e "   • ${YELLOW}pre-commit${NC}   - Validates shell scripts, YAML, and component structure"
echo -e "   • ${YELLOW}commit-msg${NC}   - Enforces commit message format and conventions"
echo -e "   • ${YELLOW}post-commit${NC}  - Provides helpful feedback after commits"
echo ""
echo -e "${BLUE}💡 Usage:${NC}"
echo -e "   • Hooks run automatically on ${YELLOW}git commit${NC}"
echo -e "   • Skip hooks with ${YELLOW}git commit --no-verify${NC}"
echo -e "   • Remove hooks by deleting files in ${YELLOW}.git/hooks/${NC}"
echo ""
echo -e "${BLUE}🔧 Requirements for optimal functionality:${NC}"
echo -e "   • Install ${YELLOW}shellcheck${NC} for shell script validation"
echo -e "   • Install ${YELLOW}yq${NC} or ensure ${YELLOW}python3${NC} is available for YAML validation"
echo ""
