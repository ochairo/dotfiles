# Dotfiles Documentation

This directory contains comprehensive documentation for the dotfiles management system.

## Documentation Structure

- [**Commands Reference**](commands/README.md) - Complete command-line interface documentation
- [**API Reference**](api/README.md) - Internal APIs and core functions
- [**Components Guide**](components/README.md) - How to create and manage components
- [**Architecture Overview**](architecture.md) - System design and structure
- [**Development Guide**](development.md) - Extending and maintaining the system
- [**Troubleshooting**](troubleshooting.md) - Common issues and solutions

## Quick Reference

### Core Commands

```bash
# Install specific components
dot install --only git,nvim,zsh

# Check component health
dot health --only nvim

# Show system status
dot status --json

# Verify integrity
dot verify

# Update repository
dot update --pull
```

### Key Concepts

- **Components**: Modular installation units in `src/components/` directory
- **Ledger**: Tracks installed symlinks and state in `~/.local/state/ochairo-dotfiles/`
- **Registry**: Component metadata and dependency management
- **Transactional**: Safe installation with rollback capabilities

## Getting Started

1. Read the [Commands Reference](commands/README.md) for available operations
2. Check the [Components Guide](components/README.md) to understand the modular system
3. See [Development Guide](development.md) if you want to extend the system

## Support

- Check [Troubleshooting](troubleshooting.md) for common issues
- Review command help: `dot help <command>`
- Run diagnostics: `dot doctor --json`
