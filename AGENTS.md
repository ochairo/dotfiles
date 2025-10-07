# AI Agent Instructions

This document provides AI-specific instructions for working with this dotfiles repository.

> **📚 For detailed technical documentation**, see [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) which covers directory structure, component creation, code style, and testing.

## Quick Reference

**Repository Type:** Modular dotfiles management system
**Primary Language:** Bash/Shell (4.0+)
**Target Platforms:** macOS, Linux (Ubuntu, Debian, Fedora, RHEL)
**Architecture:** Configuration as Code (CaC) with component-based design

## Core Principles

1. **Configuration as Code** - Declarative, version-controlled, reproducible
2. **Modularity First** - Each tool/application is a separate component
2. **Cross-Platform** - Support macOS and Linux equally
3. **Safety** - Transactional installs, backups, validation
4. **Centralization** - All configs in repository, minimal home directory pollution
5. **Dependencies** - Automatic resolution and ordering

## AI-Specific Guidelines

### When Helping Users

**Read ARCHITECTURE first**: Before making suggestions, reference [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for:

- Complete directory structure
- Component YAML schema and examples
- Shell script standards and patterns
- Core library documentation
- Testing procedures

### Most Common Tasks (90% of AI Assistance)

1. **Adding new components** → See ARCHITECTURE "Adding a New Component"
2. **Fixing component YAML** → See ARCHITECTURE "Component YAML Template"
3. **Writing postInstall scripts** → See ARCHITECTURE "Adding Configuration Files"
4. **Shell script issues** → See ARCHITECTURE "Code Style Guidelines"

### Quick Component Template

For fast reference when creating components:

```yaml
name: tool-name
description: "Brief description"
tags: [cli, development]
parallelSafe: true
critical: false
healthCheck: "command -v tool-name >/dev/null 2>&1"
requires: []
provides: []

platforms:
  macos:
    installMethod: package
    packageManager: brew
    packageName: tool-name
```

**Full details**: See ARCHITECTURE "Adding a New Component"

## Key Patterns & Quick Reference

### Logging (Never use `echo`!)

```bash
log_info "Message"
log_warn "Warning"
log_error "Error"
log_success "Success"
log_debug "Debug"
```

### Core Library Loading

```bash
core_require log fs registry
fs_symlink "$source" "$dest" "component-name"
```

### Health Check Examples

```yaml
# Command exists
healthCheck: "command -v tool >/dev/null 2>&1"

# File exists
healthCheck: "test -f ~/.config/tool/config.yml"

# Combined check
healthCheck: "command -v tool >/dev/null 2>&1 && test -f ~/.toolrc"
```

**For complete examples**: See ARCHITECTURE "Code Style Guidelines"

## What NOT to Do

### ❌ Don't

- Use `echo` instead of logging functions
- Use `exit` in sourced scripts (use `return 1`)
- Hardcode paths (use `$DOTFILES_ROOT`, `$HOME`)
- Commit secrets, keys, or personal info
- Create components without health checks
- Modify core libraries without understanding impact
- Add duplicate functionality (check existing components)

### ✅ Do

- Use logging functions consistently
- Handle errors gracefully with `return 1`
- Use environment variables for paths
- Validate with `./src/bin/dot validate`
- Test with `--dry-run` first
- Follow existing component patterns
- Keep components focused (one tool per component)

## Testing Your Changes

### Before Committing

```bash
# 1. Validate all components
./src/bin/dot validate

# 2. Test installation (dry run)
./src/bin/dot install --only your-component --dry-run

# 3. Check health
./src/bin/dot health | grep your-component

# 4. ShellCheck any scripts
shellcheck src/commands/your-script.sh
```

### After Installation

```bash
# Check status
./src/bin/dot status

# Verify health
./src/bin/dot health

# Check the ledger
cat ~/.dotfiles.ledger | grep your-component
```

## Security Guidelines

### Never Commit

- API keys, tokens, passwords (`*token*`, `*key*`, `*secret*`)
- SSH private keys (`id_*`, `*.pem`, `*.key`)
- Certificates (`.crt`, `.p12`, `.pfx`)
- Real email addresses
- Real server hostnames or IPs
- Environment files with secrets (`.env`)

### Safe to Commit

- Configuration templates
- SSH hardening settings (no real hosts)
- Public GitHub URLs
- Generic examples
- Documentation

### The .gitignore Protects

Already configured to block:

- All key/certificate files
- Secrets and tokens
- Environment files
- SSH configs with real hosts
- GPG keys

## Environment Variables

### Auto-Set (Don't Set These)

- `DOTFILES_ROOT` - Repository root (auto-detected from symlinks)
- `PROJECT_ROOT` - Project root
- `CORE_DIR` - Core libraries directory
- `COMPONENTS_DIR` - Components directory

### Optional (User Can Set)

- `DOTFILES_DEBUG=1` - Enable debug logging
- `DOTFILES_TRANSACTIONAL=1` - Enable transaction mode
- `DOTFILES_BACKUP=1` - Backup files before overwriting

## Examples

### Simple CLI Tool

```yaml
name: ripgrep
description: "Fast text search tool"
tags: [cli, search]
parallelSafe: true
critical: false
healthCheck: "command -v rg >/dev/null 2>&1"
requires: []
provides: []

platforms:
  macos:
    installMethod: package
    packageManager: brew
    packageName: ripgrep

  ubuntu:
    installMethod: package
    packageManager: apt
    packageName: ripgrep
```

### Tool with Configuration

```yaml
name: neovim
description: "Modern Vim editor"
tags: [editor, development]
parallelSafe: true
critical: false
healthCheck: "command -v nvim >/dev/null 2>&1"
requires: [fonts]
provides: []

platforms:
  macos:
    installMethod: package
    packageManager: brew
    packageName: neovim
    postInstall: |
      source "${DOTFILES_ROOT}/src/core/fs.sh"

      CONFIG_SOURCE="${DOTFILES_ROOT}/src/configs/.config/nvim"
      if [[ -d "$CONFIG_SOURCE" ]]; then
        fs_symlink "$CONFIG_SOURCE" "$HOME/.config/nvim" "neovim"
        log_success "Neovim configuration linked"
      fi
```

### Language Version Manager

```yaml
name: pyenv
description: "Python version management"
tags: [language, python, development]
parallelSafe: true
critical: false
healthCheck: "command -v pyenv >/dev/null 2>&1"
requires: []
provides: [python]

platforms:
  macos:
    installMethod: package
    packageManager: brew
    packageName: pyenv
    postInstall: |
      # Add to shell PATH
      export PYENV_ROOT="$HOME/.pyenv"
      export PATH="$PYENV_ROOT/bin:$PATH"
      eval "$(pyenv init -)"

      log_info "Installing Python 3.11..."
      pyenv install 3.11.0
      pyenv global 3.11.0

      log_success "pyenv configured with Python 3.11"
```
