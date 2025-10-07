# Documentation

Simple documentation for the dotfiles management system.

## Quick Start

```bash
# Install components
dot install --only git,nvim,zsh

# Check status
dot status

# Verify system
dot doctor

# Update repository
dot update --pull
```

## Requirements

- **Bash 4.0+** (for associative array support)
- macOS or Linux
- Git

## Components

Components are in `src/components/` directory. Each component has:

- `component.yml` - metadata and dependencies
- `install.sh` - installation script

Run `dot status` to see available components.
