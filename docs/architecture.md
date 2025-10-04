# Architecture Overview

Understanding the design and structure of the dotfiles management system.

## System Design

The dotfiles system follows a modular, component-based architecture with clear separation of concerns:

```bash
dotfiles/
├── dot                  # Main CLI entry point (contains all constants)
├── src/
│   ├── commands/       # CLI implementation
│   ├── components/     # Modular installers
│   ├── configs/        # Configuration files
│   └── core/           # Shared libraries
├── tests/              # Test suite
├── docs/               # Documentation
├── .github/            # CI/CD workflows
├── .vscode/            # VS Code settings
└── .devcontainer/      # Development container config
```

## Core Architecture

### 1. CLI Layer (`dot`)

The main entry point provides:

- Command discovery and routing
- Argument parsing and validation
- Help system integration
- Error handling and exit codes
- All path constants and environment setup

```bash
./dot <command> [args...]
```

### 2. Command Layer (`src/commands/`)

Individual command implementations:

- Self-contained bash scripts
- Standardized argument handling
- Consistent logging and error handling
- Help text integration

### 3. Core Library Layer (`core/`)

Reusable modules providing common functionality:

- **bootstrap.sh**: Module loading system
- **log.sh**: Structured logging
- **registry.sh**: Component discovery
- **fs.sh**: File system operations and symlink management

### 4. Component Layer (`components/`)

Modular installation units:

- Independent, self-contained packages
- Declarative metadata (YAML)
- Imperative installation scripts
- Health check definitions

### 5. State Layer (`state/`)

Persistent state management:

- **ledger.json**: Symlink tracking
- **selection.txt**: Component selection
- **install-timing.json**: Performance metrics

## Data Flow

```bash
User Command → CLI Router → Command Script → Core APIs → Components → File System
     ↑                                                                      ↓
State Management ←─────────── Logging & Monitoring ←──────────────────────┘
```

### Installation Flow

1. **Command Parsing**: CLI parses arguments and routes to command
2. **Component Discovery**: Registry scans and loads component metadata
3. **Dependency Resolution**: Build installation order based on dependencies
4. **Pre-flight Checks**: Validate prerequisites and conflicts
5. **Transaction Begin**: Start atomic operation tracking
6. **Component Installation**: Execute component install scripts
7. **State Recording**: Update ledger with installed artifacts
8. **Health Verification**: Run health checks
9. **Transaction Commit**: Finalize installation
10. **Cleanup**: Remove temporary files and state

### Error Handling Flow

```bash
Error Detected → Log Error → Transaction Rollback → Cleanup → Exit with Code
```

## Module System

### Bootstrap (`core/bootstrap.sh`)

Provides idempotent module loading:

```bash
# One-time initialization
source "$ROOT/core/bootstrap.sh"

# Load required modules
core_require log registry selection
```

Features:

- Prevents duplicate loading
- Dependency resolution
- Environment setup
- Path management

### Module Dependencies

```bash
bootstrap.sh
├── log.sh (no dependencies)
├── fs.sh → log.sh
├── registry.sh → log.sh, fs.sh
├── selection.sh → log.sh, fs.sh
└── transactional.sh → log.sh, fs.sh
```

## Component Architecture

### Component Lifecycle

1. **Discovery**: Registry scans component directories
2. **Registration**: Metadata parsed and validated
3. **Selection**: User selects components for installation
4. **Planning**: Dependencies resolved, order determined
5. **Installation**: Scripts executed in dependency order
6. **Verification**: Health checks confirm success
7. **Recording**: Symlinks recorded in ledger for tracking

### Component Structure

```bash
components/example/
├── component.yml       # Metadata (required)
├── install.sh         # Installation script (required)
├── health.sh          # Health check (optional)
├── files/             # Configuration files (optional)
│   ├── .config/
│   └── .local/
└── README.md          # Documentation (optional)
```

### Metadata Schema

```yaml
# Identity
name: string
description: string
version: semver
author: string

# Classification
tags: [string]
group: string
priority: integer

# Compatibility
os: [macos, linux]
arch: [x86_64, arm64]

# Dependencies
dependencies: [string]
suggests: [string]
conflicts: [string]

# Health
health: string | object

# Installation
install:
  symlinks: [object]
  commands: object
  environment: object
```

## State Management

### Ledger System

The ledger (`state/ledger.json`) tracks all managed artifacts:

```json
{
  "version": "1.0",
  "entries": [
    {
      "destination": "/home/user/.vimrc",
      "source": "/dotfiles/configs/.vimrc",
      "component": "vim",
      "type": "symlink",
      "created": "2024-01-01T12:00:00Z"
    }
  ]
}
```

### Selection Persistence

Component selections are saved for repeatability:

```bash
# state/selection.txt
git
nvim
zsh
starship
```

### Symlink Tracking

The system tracks symlinks for management and troubleshooting:

- **Destination mapping**: Source to target relationships
- **Component association**: Which component owns which symlinks
- **Status verification**: Symlink existence and correctness
- **Maintenance support**: Cleanup and repair operations

## Security Model

### File System Safety

- **Backup creation**: Before modifications
- **Atomic operations**: Via transactions
- **Permission preservation**: Maintain file modes
- **Symlink validation**: Prevent directory traversal

### Input Validation

- **Component names**: Alphanumeric with hyphens
- **File paths**: Canonical path resolution
- **Commands**: Shell injection prevention
- **YAML parsing**: Schema validation

### Privilege Separation

- **User space**: Default operation mode
- **System space**: Explicit sudo requirements
- **Component isolation**: Sandboxed execution
- **Resource limits**: Prevent resource exhaustion

## Performance Characteristics

### Startup Time

- **Cold start**: ~100ms (module loading)
- **Warm start**: ~50ms (cached state)
- **Component discovery**: O(n) where n = component count

### Memory Usage

- **Base overhead**: ~10MB (bash + modules)
- **Per component**: ~1MB (metadata + state)
- **Peak usage**: During parallel installation

### Storage Requirements

- **Core system**: ~1MB
- **Per component**: Variable (configs + metadata)
- **State files**: ~1KB per installed component

## Extensibility Points

### Custom Commands

Add new commands by creating `commands/new-command.sh`:

```bash
#!/usr/bin/env bash
# usage: dot new-command [options]
# summary: Description of new command

set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/core/bootstrap.sh"
core_require log

# Command implementation
```

### Core Modules

Extend functionality by adding modules to `core/`:

```bash
#!/usr/bin/env bash
# core/new-module.sh
# Provides: new_module_function

new_module_function() {
    # Implementation
}
```

### Component Hooks

Components can define installation hooks:

```bash
# In component install.sh
pre_install_hook() {
    # Pre-installation logic
}

post_install_hook() {
    # Post-installation logic
}
```

## Integration Points

### External Tools

The system integrates with:

- **Package Managers**: Homebrew, apt, dnf, pacman
- **Version Managers**: fnm, pyenv, rbenv, rustup
- **Shell Environments**: Zsh, Bash, Fish
- **Terminal Emulators**: WezTerm, iTerm2, Alacritty
- **Development Tools**: Git, Neovim, VS Code

### CI/CD Integration

GitHub Actions workflow provides:

- **Automated testing**: Bats test suite
- **Linting**: ShellCheck validation
- **Format checking**: shfmt formatting
- **Cross-platform testing**: macOS and Linux
- **Integration testing**: Full installation tests

### Monitoring Integration

Export metrics for external monitoring:

```bash
# JSON output for monitoring
dot status --json
dot doctor --json
dot health --json
```

## Design Principles

### 1. Modularity

- Self-contained components
- Minimal dependencies
- Clear interfaces
- Pluggable architecture

### 2. Idempotency

- Safe to run multiple times
- Consistent end state
- No side effects from re-runs
- Graceful handling of existing state

### 3. Transparency

- Detailed logging
- Clear error messages
- Dry-run capabilities
- State visibility

### 4. Safety

- Backup before modification
- Transaction support
- Rollback capabilities
- Permission validation

### 5. Cross-Platform

- OS abstraction layer
- Package manager detection
- Path handling
- Feature detection

## Future Architecture

### Planned Enhancements

1. **Plugin System**: External component repositories
2. **Web Interface**: Browser-based management
3. **Remote Sync**: Multi-machine synchronization
4. **Configuration Profiles**: Environment-specific configs
5. **Dependency Solver**: Advanced conflict resolution
6. **Performance Optimization**: Parallel execution
7. **Security Hardening**: Signature verification

### Scalability Considerations

- **Component Registry**: Support for external repositories
- **Caching Layer**: Metadata and state caching
- **Distributed State**: Multi-machine coordination
- **Event System**: Hooks and notifications
- **API Layer**: REST API for external integration
