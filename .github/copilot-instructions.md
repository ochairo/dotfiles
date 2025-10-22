# GitHub Copilot Instructions - Dotfiles Repository

## Project Overview

This is a **modular dotfiles management system** for Unix-like systems (macOS and Linux) with:
- Component-based architecture
- Cross-platform support
- Transactional installations
- Auto dependency management
- Centralized configuration

## Code Style & Standards

### Shell Scripts (Bash/Zsh)

**Requirements:**
- Bash 4.0+ compatible (uses associative arrays)
- Always use `set -euo pipefail` for error handling
- Follow Google Shell Style Guide principles
- Use shellcheck-compliant code
- 2-space indentation

**Best Practices:**
```bash
#!/usr/bin/env bash
# Brief description of script purpose

set -euo pipefail

# shellcheck source=/dev/null
source "${DOTFILES_ROOT}/core/init/bootstrap.sh"
core_require log fs registry  # Load only needed modules

# Use descriptive function names
function_name() {
  local param="${1}"

  # Early returns for error conditions
  [[ -z "${param}" ]] && log_error "Parameter required" && return 1

  # Use logging functions instead of echo
  log_info "Processing ${param}..."

  return 0
}
```

**Logging:**
- Use `log_info`, `log_warn`, `log_error`, `log_success`, `log_debug`
- Never use `echo` for user-facing messages
- Use `log_debug` for troubleshooting output

**Error Handling:**
- Check command exit codes
- Use `return 1` on errors (not `exit` in sourced scripts)
- Provide helpful error messages

### Component YAML Files

**Structure:**
```yaml
name: component-name          # Lowercase, hyphenated
description: "Brief description"
tags: [category]              # Valid: shell, cli, development, etc.
parallelSafe: true|false      # Can install in parallel?
critical: true|false          # Essential component?
healthCheck: "command -v tool >/dev/null 2>&1"
requires: [dep1, dep2]        # Component dependencies
provides: []                  # What this provides (optional)

platforms:
  macos:
    installMethod: package|script|git|binary
    packageManager: brew|apt|dnf
    packageName: package-name
    postInstall: |
      # Optional post-install script
      log_info "Additional setup..."
```

**Valid Tags:**
`shell`, `cli`, `development`, `editor`, `git`, `terminal`, `productivity`, `language`, `package-manager`, `container`, `virtualization`, `cloud`, `security`, `ui`, `system`

**Valid Install Methods:**
- `package` - Use system package manager
- `script` - Execute custom script via scriptUrl
- `git` - Clone git repository
- `binary` - Download and install binary

### Configuration Files

**Shell Configs** (`src/configs/.config/shell/`):
- Use `DOTFILES_ROOT` environment variable (auto-detected)
- Source files directly from repository (not from `$HOME`)
- Use `SHELL_CONFIG_DIR` for helper files
- Cross-platform compatible (macOS & Linux)

**Pattern:**
```bash
# Auto-detect repository location
SHELL_CONFIG_DIR="${DOTFILES_ROOT}/src/configs/.config/shell"
[[ ! -d "$SHELL_CONFIG_DIR" ]] && SHELL_CONFIG_DIR="$HOME"

# Source directly from repository
[[ -f "$SHELL_CONFIG_DIR/.zsh_lazy" ]] && source "$SHELL_CONFIG_DIR/.zsh_lazy"
```

## Core Libraries (src/core/)

**Available Modules:**
- `log.sh` - Logging functions (log_info, log_error, etc.)
- `fs.sh` - Filesystem operations (fs_symlink, fs_backup_if_exists)
- `registry.sh` - Component registry management
- `dependency.sh` - Dependency resolution
- `transactional.sh` - Transactional installations
- `validation.sh` - Component validation
- `os.sh` - OS detection utilities
- `error.sh` - Error handling
- `parallel.sh` - Parallel execution

**Usage:**
```bash
# Load only what you need
core_require log fs registry

# Then use the functions
log_info "Message"
fs_symlink "$source" "$dest" "component-name"
```

## Component Development Guidelines

### Creating a New Component

1. **Directory Structure:**
```bash
src/components/my-tool/
└── component.yml
```

2. **Minimal component.yml:**
```yaml
name: my-tool
description: "Tool description"
tags: [cli]
parallelSafe: true
critical: false
healthCheck: "command -v my-tool >/dev/null 2>&1"
requires: []
provides: []

platforms:
  macos:
    installMethod: package
    packageManager: brew
    packageName: my-tool
```

3. **With Post-Install:**
```yaml
postInstall: |
  # Load required modules
  if [[ -f "${DOTFILES_ROOT}/src/core/fs.sh" ]]; then
    source "${DOTFILES_ROOT}/src/core/fs.sh"
  fi

  # Create symlinks for configs
  CONFIG_SOURCE="${DOTFILES_ROOT}/src/configs/.config/my-tool"
  if [[ -d "$CONFIG_SOURCE" ]]; then
    fs_symlink "$CONFIG_SOURCE" "$HOME/.config/my-tool" "my-tool"
  fi

  log_success "my-tool configured successfully"
```

### Component Naming

- Use lowercase with hyphens: `my-tool`, `package-manager`
- Match the tool's common name
- Keep it short and descriptive

### Dependencies

- List all component dependencies in `requires: []`
- System will resolve and install in correct order
- Circular dependencies are detected and prevented

### Health Checks

**Good Examples:**
```yaml
# Command exists
healthCheck: "command -v tool >/dev/null 2>&1"

# File exists
healthCheck: "test -f ~/.tool/config"

# Directory exists
healthCheck: "test -d ~/.tool"

# Complex check
healthCheck: "command -v tool >/dev/null 2>&1 && test -f ~/.toolrc"
```

## CLI Commands

**Main Commands:**
- `dot install [--only comp1,comp2] [--dry-run] [--parallel]`
- `dot health` - Check component status
- `dot status` - Show installation status
- `dot validate` - Validate all components
- `dot component list` - List all components
- `dot update` - Update components

## Testing & Validation

**Before Committing:**
```bash
# Validate all components
./src/bin/dot validate

# Dry-run installation
./src/bin/dot install --dry-run

# Check specific component
./src/bin/dot health | grep component-name
```

**ShellCheck:**
- All shell scripts must pass `shellcheck`
- Use `# shellcheck disable=SCxxxx` sparingly with comments
- Run: `shellcheck src/**/*.sh`

## Environment Variables

**Auto-Set by System:**
- `DOTFILES_ROOT` - Repository root (auto-detected)
- `PROJECT_ROOT` - Project root directory
- `CORE_DIR` - Core libraries directory
- `COMPONENTS_DIR` - Components directory
- `CONFIGS_DIR` - Configurations directory
- `COMMANDS_DIR` - Commands directory

**User-Configurable:**
- `DOTFILES_DEBUG=1` - Enable debug logging
- `DOTFILES_TRANSACTIONAL=1` - Enable transactional mode
- `DOTFILES_BACKUP=1` - Backup existing files

## Security & Privacy

**Never Commit:**
- API keys, tokens, passwords
- SSH keys, certificates
- Personal email addresses
- Real server hostnames or IPs
- `.env` files with secrets

**Safe to Commit:**
- Configuration templates
- SSH hardening settings (no real hosts)
- Public GitHub repository URLs
- Generic path examples

## Common Patterns

### Symlink Management
```bash
# Load fs module
source "${DOTFILES_ROOT}/src/core/fs.sh"

# Create symlink (with backup and ledger tracking)
fs_symlink "$source_path" "$dest_path" "component-name"
```

### Cross-Platform Detection
```bash
if [[ "$(uname)" == "Darwin" ]]; then
  # macOS specific
elif [[ "$(uname)" == "Linux" ]]; then
  # Linux specific
fi
```

### Conditional Installation
```bash
if command -v tool >/dev/null 2>&1; then
  log_info "Tool already installed"
else
  log_info "Installing tool..."
fi
```

## VS Code Integration

- Use code snippets: `comp-yml`, `bash-header`, `func`, `log`
- Run tasks: `Cmd+Shift+B` for validation
- Keyboard shortcut: `Cmd+Shift+P` → "Run Task"
- Auto-format on save enabled

## Contribution Guidelines

When suggesting code:
1. Follow existing patterns and structure
2. Use core libraries instead of duplicating code
3. Add proper error handling and logging
4. Include health checks for new components
5. Test with `--dry-run` before committing
6. Ensure cross-platform compatibility
7. Update documentation if adding features

## AI Assistant Instructions

When helping with this repository:
- **Prefer** using existing core library functions over custom implementations
- **Always** include proper error handling and logging
- **Validate** component.yml against the schema
- **Consider** cross-platform compatibility (macOS & Linux)
- **Use** shellcheck-compliant shell script syntax
- **Follow** the established directory structure
- **Test** suggestions with dry-run mode
- **Document** any new patterns or utilities

## Examples

### Simple Package Component
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

### Component with Configuration
```yaml
name: starship
description: "Modern shell prompt"
tags: [shell, prompt]
parallelSafe: true
critical: false
healthCheck: "command -v starship >/dev/null 2>&1"
requires: []
provides: []

platforms:
  macos:
    installMethod: package
    packageManager: brew
    packageName: starship
    postInstall: |
      source "${DOTFILES_ROOT}/src/core/fs.sh"

      CONFIG_SOURCE="${DOTFILES_ROOT}/src/configs/.config/starship"
      if [[ -d "$CONFIG_SOURCE" ]]; then
        fs_symlink "$CONFIG_SOURCE" "$HOME/.config/starship" "starship"
        log_success "Starship configuration linked"
      fi
```

## Questions?

- Check existing components for patterns
- Review core library documentation in `src/core/`
- Run `./src/bin/dot --help` for CLI usage
- Validate with `./src/bin/dot validate`
