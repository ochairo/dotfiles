# Components Guide

Learn how to create, manage, and extend components in the dotfiles system.

## Overview

Components are the core building blocks of the dotfiles system. Each component represents a tool, application, or configuration that can be independently installed and managed.

## Component Structure

```bash
src/components/component-name/
├── component.yml          # Metadata and configuration (required)
├── install.sh            # Installation script (required)
├── health.sh             # Custom health check (optional)
├── files/                # Component-specific files (optional)
└── README.md             # Component documentation (optional)
```

## Component Metadata (`component.yml`)

The metadata file defines component properties and behavior:

```yaml
# Basic information
name: "component-name"
description: "Brief description of what this component provides"
version: "1.0.0"
author: "Your Name <email@example.com>"

# Classification
tags: [development, editor, cli]
group: "development"
priority: 50                    # Installation order (lower = earlier)

# Compatibility
os: [macos, linux]             # Supported operating systems
arch: [x86_64, arm64]          # Supported architectures

# Dependencies
dependencies: [homebrew, git]   # Required components
suggests: [fzf, ripgrep]       # Recommended components
conflicts: [vim]               # Incompatible components

# Health check
health: "nvim --version"       # Command to verify installation

# Installation configuration
install:
  # Symlinks to create
  symlinks:
    - src: "files/.config/nvim"
      dst: "~/.config/nvim"
    - src: "files/.vimrc"
      dst: "~/.vimrc"

  # Commands to run (OS-specific)
  commands:
    macos:
      - "brew install neovim"
    linux:
      - "sudo apt-get install neovim"

  # Environment variables to set
  environment:
    EDITOR: "nvim"
    VISUAL: "nvim"
```

### Metadata Fields Reference

#### Required Fields

- `name` - Component identifier (must match directory name)
- `description` - Brief description of the component

#### Optional Fields

- `version` - Component version
- `author` - Author information
- `tags` - Array of classification tags
- `group` - Logical grouping
- `priority` - Installation priority (1-1000, default 500)
- `os` - Supported operating systems
- `arch` - Supported architectures
- `dependencies` - Required components
- `suggests` - Recommended components
- `conflicts` - Incompatible components
- `health` - Health check command
- `install` - Installation configuration

#### Installation Configuration

- `symlinks` - Files/directories to symlink
- `commands` - Shell commands to execute
- `environment` - Environment variables to set
- `files` - Files to copy (instead of symlink)

## Installation Script (`install.sh`)

The installation script handles component setup:

```bash
#!/usr/bin/env bash
# Component install script for component-name
set -euo pipefail

# Available variables
# $COMPONENT_ROOT - This component's directory
# $DOTFILES_ROOT - Main dotfiles directory
# $COMPONENT_NAME - Name of this component
# $DRY_RUN - 1 if dry run mode
# $REPEAT - 1 if repeat installation

# Pre-loaded functions available:
# log_info, log_warn, log_error, log_debug
# fs_symlink, fs_backup, fs_ensure_dir
# os_is_macos, os_is_linux, os_has_command

log_info "Installing $COMPONENT_NAME"

# Check if already installed
if os_has_command "nvim"; then
    log_info "Neovim already installed"
    exit 0
fi

# Platform-specific installation
if os_is_macos; then
    if ! os_has_command "brew"; then
        log_error "Homebrew required but not found"
    fi
    brew install neovim
elif os_is_linux; then
    if os_has_command "apt-get"; then
        sudo apt-get update
        sudo apt-get install -y neovim
    elif os_has_command "dnf"; then
        sudo dnf install -y neovim
    else
        log_error "Unsupported package manager"
    fi
else
    log_error "Unsupported operating system"
fi

# Create necessary directories
fs_ensure_dir "$HOME/.config"

# Create symlinks
fs_symlink "$COMPONENT_ROOT/files/.config/nvim" "$HOME/.config/nvim"

log_info "Installation complete"
```

### Installation Script Guidelines

1. **Always use `set -euo pipefail`** for safety
2. **Check prerequisites** before installation
3. **Handle platform differences** appropriately
4. **Use provided logging functions** for output
5. **Respect `$DRY_RUN` mode** where applicable
6. **Be idempotent** - safe to run multiple times
7. **Clean up on failure** when possible

### Available Functions

Pre-loaded functions in installation scripts:

```bash
# Logging
log_info "message"      # Info level
log_warn "message"      # Warning level
log_error "message"     # Error level (exits)
log_debug "message"     # Debug level

# File system
fs_symlink "src" "dst"  # Create symlink safely
fs_backup "file"        # Create backup
fs_ensure_dir "dir"     # Create directory
fs_is_symlink "file"    # Check if symlink
fs_hash_file "file"     # Calculate hash

# OS detection
os_is_macos            # Check if macOS
os_is_linux            # Check if Linux
os_has_command "cmd"   # Check if command exists
os_get_package_manager # Get package manager
```

## Health Checks

Components can define health checks in three ways:

### 1. Simple Command (in `component.yml`)

```yaml
health: "nvim --version"
```

### 2. Custom Script (`health.sh`)

```bash
#!/usr/bin/env bash
set -euo pipefail

# Check if Neovim is installed and configured
if ! command -v nvim >/dev/null 2>&1; then
    echo "Neovim not found"
    exit 1
fi

# Check if config exists
if [[ ! -d "$HOME/.config/nvim" ]]; then
    echo "Neovim config directory missing"
    exit 1
fi

# Check if plugins are installed
if ! nvim --headless +qall 2>/dev/null; then
    echo "Neovim configuration has errors"
    exit 1
fi

echo "Neovim health check passed"
```

### 3. Automatic Detection

If no health check is specified, the system will:

1. Check if symlinks exist and are correct
2. Verify any installed commands are available
3. Validate file permissions

## Component Categories

### Standard Tags

Use these standard tags for consistency:

- **Type**: `cli`, `gui`, `library`, `config`
- **Category**: `development`, `shell`, `editor`, `system`, `security`
- **Language**: `python`, `javascript`, `rust`, `go`, `ruby`
- **Platform**: `macos`, `linux`, `unix`

### Priority Levels

- **1-10**: System essentials (homebrew, git)
- **11-20**: Shell environment (zsh, bash)
- **21-30**: Core utilities (coreutils, findutils)
- **31-50**: Development tools (editors, IDEs)
- **51-100**: Language tools (python, node, rust)
- **101-500**: Applications and extras
- **501-1000**: Experimental or optional

## Example Components

### Simple CLI Tool

```yaml
# components/bat/component.yml
name: "bat"
description: "A cat clone with syntax highlighting and Git integration"
tags: [cli, utility]
priority: 30

health: "bat --version"

install:
  commands:
    macos: ["brew install bat"]
    linux: ["sudo apt-get install bat"]
```

```bash
#!/usr/bin/env bash
# components/bat/install.sh
set -euo pipefail

log_info "Installing bat"

if os_has_command "bat"; then
    log_info "bat already installed"
    exit 0
fi

if os_is_macos; then
    brew install bat
elif os_is_linux; then
    if os_has_command "apt-get"; then
        sudo apt-get update
        sudo apt-get install -y bat
    else
        log_error "Unsupported package manager"
    fi
fi

log_info "bat installation complete"
```

### Complex Application with Config

```yaml
# components/nvim/component.yml
name: "nvim"
description: "Modern Neovim configuration with LSP support"
tags: [editor, development, lua]
priority: 40
dependencies: [git, nodejs]

health: "nvim --headless +qall"

install:
  symlinks:
    - src: "files/.config/nvim"
      dst: "~/.config/nvim"
  commands:
    macos: ["brew install neovim"]
    linux: ["sudo apt-get install neovim"]
```

## Component Development

### Creating a New Component

1. **Create component directory**:

   ```bash
   mkdir components/my-tool
   cd components/my-tool
   ```

2. **Create metadata file**:

   ```bash
   cat > component.yml << 'EOF'
   name: "my-tool"
   description: "Description of my tool"
   tags: [cli, utility]
   health: "my-tool --version"
   EOF
   ```

3. **Create installation script**:

   ```bash
   cat > install.sh << 'EOF'
   #!/usr/bin/env bash
   set -euo pipefail

   log_info "Installing my-tool"
   # Installation logic here
   log_info "Installation complete"
   EOF
   chmod +x install.sh
   ```

4. **Test the component**:

   ```bash
   # Test installation
   ./dot install --dry-run --only my-tool

   # Test health check
   ./dot health --only my-tool
   ```

### Best Practices

1. **Naming**: Use lowercase with hyphens (e.g., `my-tool`)
2. **Idempotency**: Safe to run multiple times
3. **Error handling**: Check prerequisites and fail fast
4. **Logging**: Use provided logging functions
5. **Platform support**: Handle OS differences gracefully
6. **Dependencies**: Declare all dependencies explicitly
7. **Testing**: Test on target platforms
8. **Documentation**: Include clear descriptions

### Testing Components

```bash
# Test single component
./dot install --dry-run --only my-component

# Test health check
./dot health --only my-component

# Test with validation
./dot validate

# Integration test
./dot install --only my-component
./dot verify
./dot status
```

## Advanced Features

### Conditional Installation

```bash
# In install.sh
if [[ "$USER" == "developer" ]]; then
    install_development_tools
else
    install_basic_tools
fi
```

### Configuration Templates

```bash
# Generate config from template
envsubst < "$COMPONENT_ROOT/templates/config.template" > "$HOME/.config/tool/config"
```

### Post-Installation Hooks

```bash
# In install.sh
post_install() {
    log_info "Running post-installation setup"
    # Additional setup here
}

# Register hook
trap post_install EXIT
```

### Version Management

```bash
# Check and install specific version
REQUIRED_VERSION="1.2.3"
CURRENT_VERSION=$(tool --version | grep -o '[0-9.]*')

if [[ "$CURRENT_VERSION" != "$REQUIRED_VERSION" ]]; then
    install_tool_version "$REQUIRED_VERSION"
fi
```

## Component Registry

The registry automatically discovers components by:

1. Scanning `components/` directory
2. Reading `component.yml` files
3. Building dependency graph
4. Sorting by priority and dependencies

Components are available immediately after creation without registration.

## Troubleshooting

### Common Issues

1. **Component not found**: Check directory name matches `component.yml` name
2. **Installation fails**: Check prerequisites and error logs
3. **Health check fails**: Verify health command or script
4. **Symlink conflicts**: Check for existing files at destination
5. **Permission errors**: Ensure proper file permissions

### Debugging

```bash
# Enable debug logging
DOTFILES_LOG_LEVEL=debug ./dot install --only my-component

# Dry run to preview
./dot install --dry-run --only my-component

# Check component status
./dot status --json | jq '.components."my-component"'

# Manual health check
./dot health --only my-component
```
