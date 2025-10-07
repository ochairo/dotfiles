# Commands Reference

Complete reference for all dotfiles CLI commands.

## Core Commands

### install

Install and configure components with extensive options.

```bash
dot install [--repeat] [--only <comp,...>] [--dry-run] [--parallel]
```

**Options:**

- `--only <comp1,comp2>` - Install only specified components
- `--repeat` - Reinstall components from previous selection
- `--dry-run` - Show what would be installed without executing
- `--parallel` - Install components in parallel (experimental)

**Examples:**

```bash
# Install specific development tools
dot install --only git,nvim,gh

# Dry run to preview installation
dot install --dry-run --only zsh,starship

# Reinstall from previous selection
dot install --repeat

# Install everything in parallel
dot install --parallel
```

### health

Run health checks for components to verify proper installation.

```bash
dot health [--only comp1,comp2]
```

**Options:**

- `--only <comp1,comp2>` - Check only specified components

**Examples:**

```bash
# Check all components
dot health

# Check specific components
dot health --only git,nvim,zsh

# Check shell-related components
dot health --only zsh,starship,fzf
```

### status

Show the current state of symlinks.

```bash
dot status [--json] [--quiet]
```

**Options:**

- `--json` - Output in structured JSON format
- `--quiet` - Suppress detailed output, show summary only

**Output States:**

- `OK` - Symlink exists and points to correct source
- `MISSING` - Expected symlink doesn't exist
- `BROKEN` - Symlink exists but points to wrong location or broken target
- `NOTSYMLINK` - Expected symlink is a regular file or directory

**Examples:**

```bash
# Show detailed status
dot status

# JSON output for scripts
dot status --json

# Quick summary only
dot status --quiet
```

### doctor

Comprehensive system diagnostics and health information.

```bash
dot doctor [--json]
```

**Options:**

- `--json` - Output diagnostics in JSON format

**Output Includes:**

- Repository update status
- Critical missing components
- Component selection state

**Examples:**

```bash
# Full system diagnosis
dot doctor

# JSON for monitoring systems
dot doctor --json
```

### update

Check repository status and optionally update from remote.

```bash
dot update [--json] [--pull]
```

**Options:**

- `--json` - Output status in JSON format
- `--pull` - Actually pull updates from remote

**Examples:**

```bash
# Check for updates
dot update

# Pull latest changes
dot update --pull

# JSON status for scripts
dot update --json
```

## Maintenance Commands

### compact-log

Deduplicate ledger entries, keeping only the latest entry per destination.

```bash
dot compact-log [--dry-run]
```

**Options:**

- `--dry-run` - Preview changes without modifying ledger

### ledger

Manage the symlink ledger file format and migrations.

```bash
dot ledger migrate [--dry-run]
```

**Options:**

- `--dry-run` - Preview migration without applying changes

### plugins

Manage Oh My Zsh plugin registry and active selection.

```bash
dot plugins (list|diff|sync) [--json]
```

**Subcommands:**

- `list` - Show registered and active plugins
- `diff` - Compare registry with active selection
- `sync` - Synchronize active plugins with registry

**Options:**

- `--json` - Output in JSON format

### selection-rebuild

Reconstruct the last component selection from ledger history.

```bash
dot selection-rebuild
```

## Editor Commands

### nvim-reset

Reset Neovim configuration for clean reinstallation.

```bash
dot nvim-reset [--force] [--no-backup] [--dry-run]
```

**Options:**

- `--force` - Skip confirmation prompts
- `--no-backup` - Don't create backups before removal
- `--dry-run` - Show what would be removed without executing

**Resets:**

- Configuration directory (`~/.config/nvim`)
- Data directory (`~/.local/share/nvim`)
- Cache directory (`~/.cache/nvim`)
- State directory (`~/.local/state/nvim`)

## Security Commands

### secrets-init

Initialize age/sops secret management scaffolding.

```bash
dot secrets-init [--overwrite]
```

**Options:**

- `--overwrite` - Replace existing secret configuration

## Utility Commands

### validate

Run local validation checks similar to CI environment.

```bash
dot validate
```

Performs:

- Structure validation
- Shell script linting (if tools available)
- Format checking
- Test execution
- Integrity verification
- Health diagnostics

## Command Groups

Commands are organized into logical groups:

- **Core**: `install`, `health`, `status`, `doctor`, `update`
- **Maintenance**: `compact-log`, `ledger`, `plugins`, `selection-rebuild`
- **Editor**: `nvim-reset`
- **Security**: `secrets-init`

## Global Options

Most commands support:

- `-h, --help` - Show command-specific help
- Structured output via `--json` where applicable
- Preview mode via `--dry-run` where applicable

## Exit Codes

- `0` - Success
- `1` - General error
- `2` - Invalid arguments
- `3` - Missing dependencies

## Configuration

Commands respect these environment variables:

- `DOTFILES_LOG_LEVEL` - Control logging verbosity
- `DOTFILES_ROOT` - Override dotfiles directory
- `XDG_*` - Standard XDG base directories
