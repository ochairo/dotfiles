<div align="center">

# 🔧 Dotfiles

<p>
  <a href="https://github.com/ochairo/dotfiles/actions/workflows/ci.yml" style="text-decoration: none;"><img src="https://github.com/ochairo/dotfiles/actions/workflows/ci.yml/badge.svg?style=flat-square" alt="CI Status" /></a>
  <a href="#platform-support" style="text-decoration: none;"><img src="https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-brightgreen.svg?style=flat-square" alt="Platform Support" /></a>
  <a href="https://github.com/ochairo/dotfiles/tree/main/src/components" style="text-decoration: none;"><img src="https://img.shields.io/github/directory-file-count/ochairo/dotfiles/src%2Fcomponents?type=dir&style=flat-square&label=Components&color=orange" alt="Components" /></a>
  <a href="https://github.com/ochairo/dotfiles/pulse" style="text-decoration: none;"><img src="https://img.shields.io/badge/Maintained-Yes-success.svg?style=flat-square" alt="Maintained" /></a>
  <a href="https://github.com/ochairo/dotfiles/tags" style="text-decoration: none;"><img src="https://img.shields.io/github/v/tag/ochairo/dotfiles.svg?style=flat-square&label=Version" alt="Version" /></a>
</p>

<h3>🚀 A Dotfiles Management System</h3>

<p><em>Modern development environment automation for Unix-like systems<br>
with intelligent dependency management<br>
and cross-platform support</em></p>

<br>

</div>

## Overview

- **Modular Architecture**: Component-based system for selective installation
- **Cross-Platform**: Support for macOS (Homebrew) and Linux (apt/dnf)
- **Transactional**: Safe installation with rollback capabilities
- **Modern Tools**: Pre-configured modern CLI alternatives (bat, eza, fd, ripgrep, etc.)
- **Development Ready**: IDE configurations for Neovim with LSP support
- **Shell Enhancement**: Zsh with Oh My Zsh, plugins, and custom configurations

## Components (Tools & Applications)

### Development Tools

- **nvim**: Modern Neovim configuration with LSP, completion, and plugins
- **git**: Enhanced Git configuration with aliases and settings
- **gh**: GitHub CLI for repository management
- **fnm**: Fast Node.js version manager
- **pyenv**: Python version management
- **rustup**: Rust toolchain installer
- **goenv**: Go version management

### CLI Enhancements

- **zsh**: Enhanced shell with Oh My Zsh and plugins
- **starship**: Modern, fast shell prompt
- **fzf**: Fuzzy finder for files, commands, and history
- **ripgrep**: Fast text search tool
- **bat**: Cat clone with syntax highlighting
- **eza**: Modern ls replacement
- **fd**: Find alternative
- **dust**: Disk usage analyzer

### Terminal & Productivity

- **wezterm**: Modern terminal emulator configuration
- **zellij**: Terminal multiplexer
- **direnv**: Environment variable management
- **glow**: Markdown renderer for the terminal

### Containerization & Virtualization

- **podman**: Container management
- **lima**: Linux virtual machines on macOS
- **lazydocker**: Docker management TUI

## Configuration Structure

```bash
├── dot                # Main CLI dispatcher
├── src/
│   ├── commands/      # CLI subcommands
│   ├── components/    # Modular installation units
│   ├── configs/       # Configuration files
│   └── core/          # Shared libraries
└── docs/              # Documentation
```

## Platform Support

### macOS

- Homebrew package manager
- macOS-specific optimizations
- Native terminal integration

### Linux

- APT-based distributions (Ubuntu, Debian)
- DNF-based distributions (Fedora, RHEL)
- Cross-distribution compatibility

## Customization

### Adding Components

1. Create a component directory under `src/components/`
2. Add `component.yml` with metadata
3. Create `install.sh` with installation logic
4. Test with `src/bin/dot install your-component`

### Environment Variables

- `DOTFILES_ROOT`: Points to src/ directory (auto-detected)
- `PROJECT_ROOT`: Points to project root (auto-detected)
- `XDG_CONFIG_HOME`: XDG configuration directory
- `DOTFILES_ZSH_SET_LOGIN`: Set zsh as login shell

## Requirements

### System Requirements

- **Bash 4.0+** (required for associative arrays)
- Unix-like system (macOS 10.15+, Linux)
- Git 2.0+
- curl or wget

### Package Managers

- **macOS**: Homebrew (auto-installed if missing)
- **Linux**: APT (Ubuntu/Debian) or DNF (Fedora/RHEL)

## Quick Start

```bash
# Clone the repository
git clone <repository-url> ~/dotfiles
cd ~/dotfiles

# Install core components
src/bin/dot install

# Check system health
src/bin/dot health
```

### Alternative: Direct Command Execution

If you need to install a specific component directly:

```bash
# Set environment variables and run install command
env DOTFILES_ROOT="$(pwd)/src" CORE_DIR="$(pwd)/src/core" COMPONENTS_DIR="$(pwd)/src/components" CONFIGS_DIR="$(pwd)/src/configs" COMMANDS_DIR="$(pwd)/src/commands" PROJECT_ROOT="$(pwd)" src/commands/install.sh --only component-name --dry-run

# Test all components with dry-run
env DOTFILES_ROOT="$(pwd)/src" CORE_DIR="$(pwd)/src/core" COMPONENTS_DIR="$(pwd)/src/components" CONFIGS_DIR="$(pwd)/src/configs" COMMANDS_DIR="$(pwd)/src/commands" PROJECT_ROOT="$(pwd)" src/commands/install.sh --dry-run
```
