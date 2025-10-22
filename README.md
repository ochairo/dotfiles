<div align="center">

# 🔧 Dotfiles

<p>
  <a href="https://github.com/ochairo/dotfiles/actions/workflows/ci.yml" style="text-decoration: none;"><img src="https://github.com/ochairo/dotfiles/actions/workflows/ci.yml/badge.svg?style=flat-square" alt="CI Status" /></a>
  <a href="#platform-support" style="text-decoration: none;"><img src="https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-brightgreen.svg?style=flat-square" alt="Platform Support" /></a>
  <a href="https://github.com/ochairo/dotfiles/tree/main/src/components" style="text-decoration: none;"><img src="https://img.shields.io/github/directory-file-count/ochairo/dotfiles/src%2Fcomponents?type=dir&style=flat-square&label=Components&color=orange" alt="Components" /></a>
</p>

<h3>Personal dotfiles CaC for Unix-like Systems</h3>

<p><em>Declarative, modular development environment with automatic dependency management</em></p>

<br>

</div>

## Overview

- **Configuration as Code (CaC)**: YAML-defined components for reproducible environments
- **Modular Architecture**: Component-based system for selective installation
- **Transactional**: Safe installation with rollback capabilities
- **Cross-Platform**: macOS and Linux support with automatic package manager detection
- **Shell Enhancement**: Zsh with Oh My Zsh, Starship, plugins, and custom configurations
- **Development Ready**: Neovim with LSP, language version managers, modern CLI tools

## Platform Support

- **macOS** 10.15+ (Catalina or later)
- **Linux**: Ubuntu, Debian, Fedora, RHEL

## Quick Start

### Interactive Installation (Recommended)

```bash
# Clone the repository
git clone https://github.com/ochairo/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run the interactive setup wizard
./src/bin/dot init
```

## Documentation

For detailed technical documentation and component development guide, see [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md):

---
