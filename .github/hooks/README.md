# Git Hooks Documentation

This directory contains Git hooks that automatically validate and improve code quality for the dotfiles project.

## Overview

Git hooks are scripts that run automatically at certain points in the Git workflow. Our hooks ensure code quality, enforce standards, and provide helpful feedback during development.

## Available Hooks

### 🔍 Pre-commit Hook

**Purpose**: Validates code before each commit to prevent broken or low-quality commits.

**What it checks**:

- **Shell Scripts**: Validates all `.sh` files using ShellCheck
- **YAML Files**: Validates syntax of `component.yml` files
- **Component Structure**: Ensures required files exist and are properly configured
- **Sensitive Files**: Prevents accidental commit of secrets, keys, or sensitive data
- **README Links**: Basic validation of markdown links

**Example output**:

```bash
🔍 Running pre-commit checks...
🐚 Checking shell scripts...
✅ Shell script validation
📄 Checking YAML files...
✅ YAML validation
🔧 Checking component structure...
✅ Component structure validation
🔒 Checking for sensitive files...
✅ Sensitive file check
📝 Checking README.md...
✅ README.md validation

🎉 All pre-commit checks passed!
```

**Bypassing**: Use `git commit --no-verify` to skip (not recommended)

### 📝 Commit Message Hook

**Purpose**: Enforces consistent, high-quality commit messages following best practices.

**What it validates**:

- **Length**: Subject line under 72 characters (warns at 50+)
- **Format**: No trailing periods, proper capitalization
- **Mood**: Suggests imperative mood (Add, Fix, Update vs Added, Fixed, Updated)
- **Conventions**: Recommends conventional commit format for component changes

**Good commit messages**:

```bash
✅ Add nvim component with LSP configuration
✅ Fix shell script validation in pre-commit hook
✅ Update README with installation instructions
✅ feat: add zsh component with Oh My Zsh
✅ fix: resolve YAML parsing error in component.yml
```

**Bad commit messages**:

```bash
❌ added stuff.
❌ This is a very long commit message that exceeds the recommended character limit
❌ Fixed the thing that was broken before.
```

### 🎉 Post-commit Hook

**Purpose**: Provides helpful feedback and suggestions after successful commits.

**What it shows**:

- **Commit Summary**: Hash, author, files changed
- **Change Analysis**: Types of files modified (components, configs, docs)
- **Next Steps**: Suggested commands to run
- **New Components**: Highlights newly added components

**Example output**:

```bash
🎉 Commit successful!
📝 Commit: a1b2c3d
👤 Author: John Doe
📂 Files changed: 3
🔧 Components modified: 1
📚 Documentation updated: 1 files

💡 Next steps:
   • Test installation: src/bin/dot install
   • Check health: src/bin/dot health
   • Validate: src/bin/dot validate

🆕 New components detected:
   • nvim
💡 Don't forget to test the new component(s)!
```

## Installation

### Automatic Setup (Recommended)

Run the setup script from the project root:

```bash
./.github/setup-hooks.sh
```

This script will:

- Install all hooks to `.git/hooks/`
- Make them executable
- Backup any existing hooks
- Provide installation feedback

### Manual Setup

Copy hooks manually:

```bash
# Make hooks executable
chmod +x .github/hooks/*

# Copy to git hooks directory
cp .github/hooks/pre-commit .git/hooks/
cp .github/hooks/commit-msg .git/hooks/
cp .github/hooks/post-commit .git/hooks/
```

## Requirements

For optimal functionality, install these tools:

### Required

- **Git**: Version 2.0+
- **Bash**: Version 4.0+

### Recommended

- **ShellCheck**: For shell script validation

  ```bash
  # macOS
  brew install shellcheck

  # Ubuntu/Debian
  sudo apt install shellcheck

  # Fedora
  sudo dnf install shellcheck
  ```

- **yq**: For YAML validation (alternative: Python 3)

  ```bash
  # macOS
  brew install yq

  # Or use Python 3 (usually pre-installed)
  python3 --version
  ```

## Configuration

### Customizing Checks

Edit the hook files to modify validation:

**Pre-commit customization**:

```bash
# Edit .github/hooks/pre-commit
# Modify sensitive_patterns array to add/remove file patterns
# Adjust shellcheck options
# Add custom validation steps
```

**Commit message customization**:

```bash
# Edit .github/hooks/commit-msg
# Modify length limits
# Add custom message patterns
# Adjust conventional commit suggestions
```

### Disabling Specific Checks

Comment out sections in the pre-commit hook:

```bash
# Disable shell script checking
# echo "🐚 Checking shell scripts..."
# if command -v shellcheck >/dev/null 2>&1; then
#   ... shellcheck logic ...
# fi
```

## Troubleshooting

### Common Issues

**Hook not running**:

```bash
# Check if hook is executable
ls -la .git/hooks/pre-commit

# Make executable if needed
chmod +x .git/hooks/pre-commit
```

**ShellCheck not found**:

```bash
# Install ShellCheck
brew install shellcheck  # macOS
sudo apt install shellcheck  # Ubuntu
```

**YAML validation failing**:

```bash
# Install yq or ensure Python 3 is available
brew install yq  # macOS
python3 --version  # Check Python availability
```

**Hooks too strict**:

```bash
# Bypass hooks for emergency commits
git commit --no-verify -m "Emergency fix"

# Or modify hook files to be less strict
```

### Debugging

Enable verbose output by adding debug flags:

```bash
# Add to top of hook file
set -x  # Enable debug mode
```

View hook execution:

```bash
# Check hook output
git commit  # Will show all hook output

# Test hook manually
./.git/hooks/pre-commit
```

## Best Practices

### For Developers

1. **Install hooks early**: Run setup script after cloning
2. **Don't bypass unnecessarily**: Hooks catch real issues
3. **Fix issues don't skip**: Address validation failures
4. **Update hooks**: Pull latest hook improvements

### For Contributors

1. **Test hooks locally**: Ensure they work in your environment
2. **Document changes**: Update this file when modifying hooks
3. **Consider compatibility**: Ensure hooks work on macOS and Linux
4. **Keep hooks fast**: Avoid slow operations in hooks

### For Maintainers

1. **Review hook changes carefully**: Hooks affect all developers
2. **Test on multiple platforms**: Ensure cross-platform compatibility
3. **Keep dependencies minimal**: Avoid requiring exotic tools
4. **Provide clear error messages**: Help developers fix issues quickly

## Integration with CI/CD

These hooks complement CI/CD pipelines:

**Local hooks** (pre-commit):

- Fast feedback during development
- Catch issues before push
- Improve developer experience

**CI/CD validation**:

- Comprehensive testing
- Multiple platform validation
- Integration tests
- Deployment checks

Both work together for comprehensive quality assurance.

## Hook Development

### Adding New Hooks

1. Create hook file in `.github/hooks/`
2. Make it executable: `chmod +x .github/hooks/new-hook`
3. Test locally: `./.github/hooks/new-hook`
4. Update setup script to include new hook
5. Document in this file

### Hook Template

```bash
#!/usr/bin/env bash
# Description of what this hook does
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Running [hook-name] checks..."

# Your validation logic here
if [[ condition ]]; then
    echo -e "${GREEN}✅ Check passed${NC}"
else
    echo -e "${RED}❌ Check failed${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 [Hook-name] completed successfully!${NC}"
```

## References

- [Git Hooks Documentation](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [ShellCheck](https://www.shellcheck.net/)
- [Dotfiles Project Structure](../docs/architecture.md)
