# GitHub Copilot Instructions for Dotfiles Project

## Project Overview
This is a sophisticated dotfiles management system for Unix-like systems (macOS, Linux) that provides automated setup of development environments with modular component architecture.

## Code Style & Standards

### Shell Scripts
- Use `#!/usr/bin/env bash` shebang
- Enable strict mode: `set -euo pipefail`
- Use 2-space indentation
- Follow shellcheck recommendations
- Prefer `[[ ]]` over `[ ]` for conditionals
- Use `"$var"` for variable expansion (always quoted)
- Use `local` for function variables

### YAML Configuration
- Use 2-space indentation
- Quote strings with special characters
- Use descriptive keys and values
- Follow component.yml schema structure

### Documentation
- Use Markdown format
- Include code examples with proper syntax highlighting
- Keep line length under 120 characters
- Use clear, concise descriptions

## Project Structure

### Core Components
- `src/dot` - Main CLI dispatcher
- `src/core/` - Core system functions and utilities
- `src/commands/` - CLI command implementations
- `src/components/` - Modular installation components
- `src/configs/` - Configuration files and templates

### Component Structure
Each component should have:
- `component.yml` - Metadata and configuration
- `install.sh` - Installation script
- Optional: configuration files, templates

## Key Patterns

### Component Development
```yaml
# component.yml structure
name: component-name
version: 1.0.0
description: Brief description
requires: [dependencies]
critical: false
tags: [category, type]
healthCheck: "command to verify installation"
```

### Installation Scripts
```bash
#!/usr/bin/env bash
set -euo pipefail

# Check if already installed
if command -v tool >/dev/null 2>&1; then
  echo "Tool already installed"
  exit 0
fi

# Install logic here
```

### Error Handling
- Always use `set -euo pipefail`
- Check command existence before execution
- Provide meaningful error messages
- Use exit codes appropriately

## Platform Considerations
- Support both macOS and Linux
- Use package managers: Homebrew (macOS), apt/dnf (Linux)
- Check OS type before platform-specific operations
- Use XDG Base Directory specification

## Dependencies
- Bash 4.0+ or Zsh 5.0+
- Git
- curl or wget
- Platform-specific package managers

## Naming Conventions
- Use kebab-case for component names
- Use snake_case for shell variables
- Use UPPER_CASE for environment variables
- Use descriptive function names

## Testing
- Verify installations work on both macOS and Linux
- Test with fresh environments
- Validate component health checks
- Ensure rollback capabilities work

When generating code for this project, prioritize:
1. Cross-platform compatibility
2. Error handling and safety
3. Modular, reusable components
4. Clear documentation
5. Following established patterns
