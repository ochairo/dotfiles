# Architecture & Development Guide

This guide documents the architecture, directory structure, and development patterns for this dotfiles repository.

## Architecture Overview

This system implements **Configuration as Code (CaC)** with a **Component-Based Architecture**:

- **Configuration as Code (CaC)**: Declarative, version-controlled, reproducible configuration management
- **Component-Based/Modular**: Self-contained components with explicit dependencies
- **Plugin System**: Dynamic discovery, automatic dependency resolution, registry tracking
- **Command Dispatcher**: Central CLI routes to subcommands with dynamic discovery
- **Transactional**: Atomic operations with rollback, state tracking, safe symlinks

**CaC vs IaC**: CaC configures existing systems (applications, shells, editors). IaC provisions infrastructure
(VMs, networks, cloud resources). This is CaC—it manages dotfiles and development tools, not infrastructure.

**Similar systems**: NixOS (declarative OS), Ansible (automation), Homebrew Bundle—but purpose-built for
dotfiles with automatic dependency management.

## Directory Structure

```bash
dotfiles/
├── src/
│   ├── bin/
│   │   └── dot                    # Main CLI dispatcher
│   ├── commands/                  # CLI subcommands (organized by purpose)
│   │   ├── setup/                 # Setup & installation commands
│   │   │   ├── init.sh            # Interactive wizard
│   │   │   ├── install.sh         # Installation logic
│   │   │   └── update.sh          # Update command
│   │   ├── diagnostic/            # Health & validation commands
│   │   │   ├── health.sh          # Health check command
│   │   │   ├── status.sh          # Status reporting
│   │   │   ├── validate.sh        # Component validation
│   │   │   └── doctor.sh          # System diagnostics
│   │   ├── component/             # Component management
│   │   │   ├── component.sh       # Component CLI
│   │   │   ├── dependency-graph.sh
│   │   │   └── selection-rebuild.sh
│   │   └── maintenance/           # Maintenance utilities
│   │       ├── ledger.sh          # Ledger management
│   │       ├── compact-log.sh     # Log compaction
│   │       ├── nvim-reset.sh      # Neovim reset
│   │       └── secrets-init.sh    # Secrets initialization
│   ├── components/                # Component definitions (one per directory)
│   │   ├── git/
│   │   │   └── component.yml      # Component metadata and install config
│   │   ├── zsh/
│   │   │   └── component.yml
│   │   └── ...
│   ├── configs/                   # Configuration files
│   │   ├── .config/               # XDG-compliant configs
│   │   │   ├── shell/             # Shell configurations
│   │   │   ├── nvim/              # Neovim config
│   │   │   ├── starship/          # Starship config
│   │   │   ├── wezterm/           # WezTerm config
│   │   │   ├── zellij/            # Zellij config
│   │   │   └── ...
│   │   └── .ssh/                  # SSH configurations
│   └── core/                      # Shared libraries (organized by responsibility)
│       ├── init/                  # Bootstrap & initialization
│       │   ├── bootstrap.sh       # Core library loader
│       │   └── constants.sh       # Constants and paths
│       ├── io/                    # I/O & user interaction
│       │   ├── log.sh             # Logging functions
│       │   ├── ui.sh              # UI utilities (colors, prompts, formatting)
│       │   └── term.sh            # Terminal utilities
│       ├── fs/                    # Filesystem operations
│       │   ├── fs.sh              # File operations, symlinks
│       │   └── transactional.sh   # Transactional operations
│       ├── component/             # Component management
│       │   ├── registry.sh        # Component tracking
│       │   ├── categories.sh      # Component categorization
│       │   ├── validation.sh      # Component validation
│       │   └── dependency.sh      # Dependency resolution
│       ├── install/               # Installation logic
│       │   ├── install_helpers.sh # Installation helpers
│       │   └── parallel.sh        # Parallel execution
│       ├── system/                # System utilities
│       │   ├── os.sh              # OS detection
│       │   └── error.sh           # Error handling
│       └── wizard/                # Interactive wizards
│           └── presets.sh         # Installation presets & selections
├── tests/                         # Test suite
│   └── bats/                      # Bats test files
├── .vscode/                       # VS Code configuration
│   ├── tasks.json                 # Build tasks
│   ├── shellscript.code-snippets  # Code snippets
│   └── ...
├── .github/
│   └── copilot-instructions.md    # GitHub Copilot instructions
├── docs/
│   └── ARCHITECTURE.md            # This file
├── AGENTS.md                      # AI agent instructions
└── README.md                      # Project documentation
```

## Adding a New Component

Components are the heart of this system. Each component represents a tool or application to be installed.

### 1. Create Component Directory

```bash
mkdir -p src/components/my-tool
```

### 2. Create component.yml

Create `src/components/my-tool/component.yml`:

```yaml
name: my-tool                      # lowercase-with-hyphens
description: "Brief description"
tags: [cli, development]           # Valid tags (see below)
parallelSafe: true                 # Can install in parallel?
critical: false                    # Essential for system?
healthCheck: "command -v my-tool >/dev/null 2>&1"
requires: []                       # Component dependencies
provides: []                       # Optional: what this provides

platforms:
  macos:
    installMethod: package         # package|script|git|binary
    packageManager: brew           # brew|apt|dnf
    packageName: my-tool
```

### 3. Valid Tags

Use appropriate tags from:

- `shell`, `cli`, `development`, `editor`, `git`, `terminal`
- `productivity`, `language`, `package-manager`, `container`
- `virtualization`, `cloud`, `security`, `ui`, `system`

### 4. Install Methods

- **package**: Use system package manager (most common)
- **script**: Execute custom script from URL
- **git**: Clone git repository
- **binary**: Download and install binary

### 5. Adding Configuration Files

If your component needs config files:

1. Place configs in `src/configs/.config/my-tool/`
2. Add `postInstall` script to create symlinks:

```yaml
platforms:
  macos:
    installMethod: package
    packageManager: brew
    packageName: my-tool
    postInstall: |
      # Load required libraries
      if [[ -f "${DOTFILES_ROOT}/src/core/fs.sh" ]]; then
        source "${DOTFILES_ROOT}/src/core/fs.sh"
      fi

      # Define source in repository
      CONFIG_SOURCE="${DOTFILES_ROOT}/src/configs/.config/my-tool"

      # Create symlink if config exists
      if [[ -d "$CONFIG_SOURCE" ]]; then
        fs_symlink "$CONFIG_SOURCE" "$HOME/.config/my-tool" "my-tool"
        log_success "Configuration linked"
      fi
```

### 6. Testing Your Component

```bash
# Validate component YAML
./src/bin/dot validate

# Test installation (dry run)
./src/bin/dot install --only my-tool --dry-run

# Install for real
./src/bin/dot install --only my-tool

# Check health
./src/bin/dot health | grep my-tool
```

## Code Style Guidelines

### Shell Scripts

**Requirements:**

- Bash 4.0+ compatible
- Use `set -euo pipefail` for error handling
- 2-space indentation
- ShellCheck compliant

**Example:**

```bash
#!/usr/bin/env bash
# Brief description

set -euo pipefail

# shellcheck source=/dev/null
source "${DOTFILES_ROOT}/core/bootstrap.sh"
core_require log fs  # Load only needed modules

function install_something() {
  local package="${1}"

  # Validation
  [[ -z "${package}" ]] && log_error "Package required" && return 1

  # Use logging functions (never echo)
  log_info "Installing ${package}..."

  # Error handling
  if ! brew install "${package}"; then
    log_error "Failed to install ${package}"
    return 1
  fi

  log_success "Installed ${package}"
  return 0
}
```

### Logging

**Always use logging functions:**

```bash
log_info "Informational message"
log_warn "Warning message"
log_error "Error occurred"
log_success "Operation completed"
log_debug "Debug information"
```

**Never use `echo` for user-facing messages!**

### Error Handling

- Check command exit codes
- Use `return 1` on errors (not `exit` in sourced scripts)
- Provide helpful error messages
- Validate inputs early

## Core Libraries

Available via `core_require`:

- `log` - Logging functions
- `fs` - Filesystem operations (symlinks, backups)
- `registry` - Component tracking
- `dependency` - Dependency resolution
- `os` - Platform detection
- `validation` - Component validation
- `transactional` - Transactional installs
- `parallel` - Parallel execution

**Usage:**

```bash
core_require log fs registry
fs_symlink "$source" "$dest" "component-name"
```

## Testing

### Before Committing

```bash
# 1. Validate all components
./src/bin/dot validate

# 2. Run ShellCheck on scripts
shellcheck src/**/*.sh

# 3. Test installation
./src/bin/dot install --only your-component --dry-run

# 4. Check health
./src/bin/dot health
```

### Running Test Suite

```bash
# Run all tests
bats tests/bats/*.bats

# Run specific test
bats tests/bats/01_install_helpers_core.bats
```

## Development Workflow

1. **Create a branch**: `git checkout -b feature/my-component`
2. **Add your component** following the guidelines above
3. **Test thoroughly** with `--dry-run` and actual installation
4. **Validate**: Run `./src/bin/dot validate`
5. **ShellCheck**: Ensure scripts pass `shellcheck`
6. **Commit**: Use clear commit messages (e.g., `feat: add ripgrep component`)

## Commit Message Convention

Follow conventional commits:

- `feat: add new component or feature`
- `fix: bug fix`
- `docs: documentation changes`
- `refactor: code refactoring`
- `test: add or update tests`
- `chore: maintenance tasks`

## Security Guidelines

**Never commit:**

- API keys, tokens, passwords
- SSH private keys, certificates
- Real email addresses (use placeholders)
- Real server hostnames or IPs
- `.env` files with secrets

**The `.gitignore` already protects against common mistakes.**

## Getting Help

- **Check existing components**: Browse `src/components/` for examples
- **Read AI documentation**: See `AGENTS.md` and `.github/copilot-instructions.md`
- **Ask questions**: Open an issue for clarification
- **Use VS Code**: Configured with tasks and snippets for faster development

## Component Development Tips

1. **Start simple**: Most components just need `package` install method
2. **Copy existing patterns**: Look at similar components
3. **Test incrementally**: Use `--dry-run` frequently
4. **Health checks are important**: Make them reliable
5. **Document dependencies**: List them in `requires: []`
6. **Keep it focused**: One tool per component
7. **XDG-compliant**: Use `.config/` for configs when possible

## Additional Documentation

- `README.md` - User guide and quick start
- `AGENTS.md` - AI agent instructions and quick reference
- `.github/copilot-instructions.md` - GitHub Copilot project standards
