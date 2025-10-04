# API Reference

Internal APIs and core functions available to commands and components.

## Core Modules

The dotfiles system is built on modular core libraries located in `src/core/`. Each module provides specific functionality that can be imported using `core_require`.

### Bootstrap System

```bash
# Load core modules
source "$CORE_DIR/bootstrap.sh"
core_require log registry selection fs
```

The bootstrap system provides:

- Idempotent module loading
- Dependency management
- Environment setup

## Core APIs

### Logging (`log.sh`)

Structured logging with multiple levels and output formatting.

#### Functions

```bash
log_error "message"    # Error level, exits with code 1
log_warn "message"     # Warning level
log_info "message"     # Info level (default)
log_debug "message"    # Debug level (if enabled)
log_trace "message"    # Trace level (if enabled)
```

#### Log Environment Variables

```bash
DOTFILES_LOG_LEVEL=debug    # Set logging level
DOTFILES_LOG_JSON=1         # Enable JSON output
DOTFILES_LOG_COLOR=0        # Disable colored output
```

#### Examples

```bash
core_require log

log_info "Starting installation"
log_debug "Processing component: $component"
log_warn "Component already installed"
log_error "Installation failed"  # Exits with code 1
```

### Registry (`registry.sh`)

Component discovery and metadata management.

#### Registry Functions

```bash
registry_list_components                    # List all available components
registry_component_exists "component"       # Check if component exists
registry_get_metadata "component" "field"   # Get component metadata
registry_get_dependencies "component"       # Get component dependencies
registry_validate_component "component"     # Validate component structure
```

#### Registry Examples

```bash
core_require registry

# List all components
components=($(registry_list_components))

# Check component existence
if registry_component_exists "nvim"; then
    log_info "Neovim component found"
fi

# Get component metadata
description=$(registry_get_metadata "nvim" "description")
tags=$(registry_get_metadata "nvim" "tags")
```

### Selection (`selection.sh`)

Manage component selection state and persistence.

#### Selection Functions

```bash
selection_save "comp1 comp2 comp3"    # Save component selection
selection_load                        # Load saved selection
selection_clear                       # Clear saved selection
selection_add "component"             # Add component to selection
selection_remove "component"          # Remove component from selection
selection_contains "component"        # Check if component is selected
```

#### Selection Examples

```bash
core_require selection

# Save current selection
selection_save "git nvim zsh starship"

# Load previous selection
previous=$(selection_load)
echo "Previous selection: $previous"

# Check if component was selected
if selection_contains "nvim"; then
    log_info "Neovim was previously selected"
fi
```

### File System (`fs.sh`)

Safe file system operations with transactional support.

#### File System  Functions

```bash
fs_symlink "source" "destination"     # Create symlink safely
fs_backup "file"                      # Create timestamped backup
fs_restore "backup"                   # Restore from backup
fs_remove_safe "file"                 # Remove with confirmation
fs_ensure_dir "directory"             # Create directory if missing
fs_is_symlink "file"                  # Check if file is symlink
fs_symlink_target "file"              # Get symlink target
fs_hash_file "file"                   # Calculate file hash
```

#### File System  Examples

```bash
core_require fs

# Create symlink with safety checks
fs_symlink "$ROOT/configs/.vimrc" "$HOME/.vimrc"

# Backup before modification
backup=$(fs_backup "$HOME/.zshrc")
# ... modify file ...
# Restore if needed
fs_restore "$backup"

# Safe directory creation
fs_ensure_dir "$HOME/.config/nvim"
```

### Symlink Management (`fs.sh`)

Create and track symlinks between config files and their destinations.

#### Symlink Functions

```bash
fs_symlink "source" "dest" ["component"]  # Create symlink and record
fs_symlink_component_files "component"    # Link files based on component.yml
fs_remove_or_backup "path"                # Remove or backup existing file
fs_backup_if_exists "path"                # Create backup if file exists
```

#### Symlink Examples

```bash
fs_symlink "$CONFIG_DIR/.vimrc" "$HOME/.vimrc" "vim"
fs_symlink_component_files "nvim"
```

### Transactional Operations (`transactional.sh`)

Atomic operations with rollback capabilities.

#### Transactional Operations Functions

```bash
transaction_begin                      # Start transaction
transaction_add_symlink "src" "dst"   # Add symlink to transaction
transaction_add_file "file"           # Add file operation to transaction
transaction_commit                    # Commit all operations
transaction_rollback                  # Rollback all operations
transaction_cleanup                   # Clean up transaction state
```

#### Transactional Operations Examples

```bash
core_require transactional

transaction_begin
transaction_add_symlink "$ROOT/configs/.vimrc" "$HOME/.vimrc"
transaction_add_symlink "$ROOT/configs/.zshrc" "$HOME/.zshrc"

if some_condition; then
    transaction_commit
else
    transaction_rollback
fi
```

### OS Detection (`os.sh`)

Cross-platform compatibility utilities.

#### OS Detection Functions

```bash
os_detect                             # Detect operating system
os_is_macos                          # Check if running on macOS
os_is_linux                          # Check if running on Linux
os_get_package_manager               # Get system package manager
os_has_command "command"             # Check if command exists
```

#### OS Detection Examples

```bash
core_require os

if os_is_macos; then
    # macOS-specific code
    brew install something
elif os_is_linux; then
    # Linux-specific code
    if [[ $(os_get_package_manager) == "apt" ]]; then
        sudo apt install something
    fi
fi
```

### Parallel Execution (`parallel.sh`)

Parallel task execution with job control.

#### Parallel Execution Functions

```bash
parallel_init "max_jobs"              # Initialize parallel executor
parallel_add_job "command" "args"     # Add job to queue
parallel_wait_all                     # Wait for all jobs to complete
parallel_get_results                  # Get job results
```

### Update Management (`update.sh`)

Repository update and version management.

#### Update Management Functions

```bash
update_check_available                # Check if updates available
update_get_current_ref               # Get current git reference
update_get_remote_ref                # Get remote git reference
update_pull_changes                  # Pull changes from remote
update_status_json                   # Get update status as JSON
```

## Component APIs

### Component Structure

Each component follows a standard structure:

```bash
components/component-name/
├── component.yml          # Metadata and configuration
├── install.sh            # Installation script
└── files/                # Optional: component-specific files
```

### Component Metadata (`component.yml`)

```yaml
name: component-name
description: "Component description"
version: "1.0.0"
author: "Author Name"
tags: [tag1, tag2]
priority: 50                # Installation priority (lower = earlier)
os: [macos, linux]          # Supported operating systems
dependencies: [dep1, dep2]   # Component dependencies
conflicts: [conf1]          # Conflicting components

# Health check command
health: "command --version"

# Installation configuration
install:
  symlinks:
    - src: "files/.config/tool/config"
      dst: "~/.config/tool/config"
  commands:
    - "brew install tool"
```

### Component Installation API

Component install scripts have access to:

```bash
# Pre-loaded functions
log_info, log_warn, log_error, log_debug
fs_symlink, fs_backup, fs_ensure_dir
os_is_macos, os_is_linux, os_has_command

# Environment variables
$COMPONENT_ROOT              # Component directory
$DOTFILES_ROOT              # Main dotfiles directory
$DRY_RUN                    # 1 if dry run mode
$REPEAT                     # 1 if repeat installation
$COMPONENT_NAME             # Current component name
```

### Component Health Checks

Health checks can be:

1. **Command-based**: Specified in `component.yml`
2. **Script-based**: Custom `health.sh` script
3. **Auto-detected**: Based on installation artifacts

## Error Handling

### Exit Codes

Standard exit codes across the system:

```bash
0   # Success
1   # General error
2   # Invalid arguments
3   # Missing dependencies
4   # Permission denied
5   # Component not found
6   # Installation failed
7   # Health check failed
```

### Error Propagation

Errors are propagated through:

1. Exit codes
2. Log levels (error logs trigger exits)
3. Transaction rollbacks
4. Health check failures

## Configuration

### Environment Variables

```bash
# Core configuration
DOTFILES_ROOT="/path/to/dotfiles"
DOTFILES_LOG_LEVEL="info"
DOTFILES_LOG_JSON="0"
DOTFILES_DRY_RUN="0"

# XDG Base Directory Specification
XDG_CONFIG_HOME="$HOME/.config"
XDG_DATA_HOME="$HOME/.local/share"
XDG_CACHE_HOME="$HOME/.cache"
XDG_STATE_HOME="$HOME/.local/state"

# Component-specific
COMPONENT_INSTALL_PARALLEL="0"
COMPONENT_HEALTH_TIMEOUT="30"
```

### File Paths

```bash
# State files
$DOTFILES_ROOT/state/ledger.json        # Symlink ledger
$DOTFILES_ROOT/state/selection.txt      # Component selection
$DOTFILES_ROOT/state/install-timing.json # Installation timing

# Resources
## Directory Structure

Core directory layout and environment variables:

```bash
$DOTFILES_ROOT/src/commands/            # CLI commands
$DOTFILES_ROOT/src/core/                # Core modules
$DOTFILES_ROOT/src/configs/             # Configuration files
$DOTFILES_ROOT/src/components/          # Component modules
$DOTFILES_ROOT/state/                   # Runtime state
```
```

## Extension Points

### Custom Commands

Add new commands by creating `commands/command-name.sh`:

```bash
#!/usr/bin/env bash
# usage: dot command-name [options]
# summary: Brief description
# group: groupname

set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/core/bootstrap.sh"
core_require log

# Command implementation
```

### Custom Components

Create new components in `components/`:

1. Create component directory
2. Add `component.yml` metadata
3. Create `install.sh` script
4. Optional: Add health checks, files, documentation

### Hook System

Components can define hooks:

```bash
# In component install.sh
pre_install_hook() {
    log_info "Preparing installation"
}

post_install_hook() {
    log_info "Installation complete"
}
```

## Testing

### Test Framework

The system includes a test framework using Bats:

```bash
# Run all tests
bats tests/

# Run specific test
bats tests/component-test.bats

# Test with coverage
COVERAGE=1 bats tests/
```

### Mock APIs

Test utilities provide mocking:

```bash
# In test files
load test_helper

mock_command "git" "echo mocked-git"
mock_fs_operation "symlink"
```
