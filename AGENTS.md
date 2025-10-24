# AI Agent Instructions

> **📚 Full technical documentation**: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)

## Quick Reference

- **Type**: Modular dotfiles management system  
- **Language**: Bash/Shell (bash 3.2+ for macOS compatibility)
- **Platforms**: macOS, Linux (Ubuntu, Debian, Fedora, RHEL)
- **CLI**: `./src/cli/bin/dot` (commands in `src/commands/`)

## Core Principles

1. **Configuration as Code** - Declarative, version-controlled
2. **Component-Based** - Each tool is a separate component in `src/components/`
3. **Cross-Platform** - Use bash 3.2 compatible syntax (`tr` not `${var,,}`)
4. **Safe** - Use new `src/lib/` APIs: `msg_*`, `components_*`, `ledger_*`, `ui_*`

## Most Common AI Tasks

1. **Add component** → Use template below + see ARCHITECTURE
2. **Fix shell script** → Use `msg_info` not `echo`, check bash 3.2 compatibility
3. **Write postInstall** → Source from `$DOTFILES_ROOT`, use `src/lib/` functions
4. **Debug CI** → macOS = bash 3.2, Ubuntu = bash 5.x

## Quick Component Template

```yaml
name: tool-name
description: "Brief description"
tags: [cli]
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

## Key APIs (src/lib/)

```bash
# Messaging (NOT echo!)
msg_info "Message"
msg_warn "Warning" 
msg_error "Error"
msg_success "Done"

# Components
components_list              # List all components
components_get "name"        # Get component data

# Ledger
ledger_add "target" "component" "type"
ledger_has "target"

# UI
ui_select "prompt" "${options[@]}"
ui_multi_select "prompt" "${options[@]}"
ui_confirm "prompt"
```

## Testing

```bash
# Before commit
./tests/run_tests.sh              # Run all 57 tests
./src/cli/bin/dot validate        # Validate components

# CI checks
- macOS & Ubuntu tests (bash 3.2 & 5.x)
- ShellCheck (excludes src/configs, *.zsh)
```

## ❌ Never

- `echo` (use `msg_*`)
- `exit` in sourced scripts (use `return 1`)
- bash 4+ syntax like `${var,,}` (use `tr`)
- Hardcoded paths (use `$DOTFILES_ROOT`)
- Commit secrets/keys

## ✅ Always

- Reference ARCHITECTURE.md for details
- Test locally before pushing
- Use bash 3.2 compatible syntax
- Follow existing patterns in `src/components/`

## Security

**.gitignore blocks**: `*key*`, `*token*`, `*secret*`, `.env`, SSH keys, certificates

**Safe to commit**: Config templates, public URLs, documentation

## Examples

See full examples in ARCHITECTURE.md or existing components in `src/components/`:

- Simple: `ripgrep/`, `bat/`, `eza/`
- With config: `neovim/`, `starship/`, `git/`
- Complex: `pyenv/`, `rbenv/`, `fnm/`
