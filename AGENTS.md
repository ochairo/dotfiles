# AI Agent Instructions

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
# Messaging (NOT echo for errors/warnings/info!)
msg_info "Message"      # Use for user-facing informational messages
msg_warn "Warning"      # Use for warnings (e.g., "No results found")
msg_error "Error"       # Use for errors (e.g., "Invalid input")
msg_success "Done"      # Use for success messages
msg_dim "Status"        # Use for dimmed/muted text (status displays, no icon)

# Primitives (building blocks)
msg_print "fmt" args... # Flexible printf to stderr
msg_blank               # Print blank line to stderr
msg_with_icon "✓" "$C_GREEN" "text"  # Icon + color + text
msg_prompt              # Print ❯ prompt without newline

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

## Library Dependency Architecture

**Principle**: Higher-level libraries depend on lower-level ones.

```text
src/lib/
├── colors.sh           # Base: Color constants (C_RED, C_GREEN, etc.)
├── primitives/         # Level 1: Basic operations using colors
│   └── msg.sh          # msg_info, msg_warn, msg_error (for messages)
├── userinterfaces/     # Level 2: Interactive UI (depends on primitives)
│   ├── input.sh        # Use msg_* for errors/warnings
│   ├── select.sh       # Use msg_* for errors/warnings
│   └── multiselect.sh  # Use msg_* for errors/warnings
│                       # BUT: Use colors directly for UI elements (checkboxes, titles)
└── utilities/          # Level 2: Business logic (depends on primitives)
```

**Rule of thumb:**

- **User messages** (errors, warnings, info) → Use `msg_*` functions
  - Examples: "No options provided", "Invalid selection", "Component not found"
- **UI display elements** (checkboxes, titles, state displays) → Use colors directly (`C_*`)
  - Examples: Checkboxes (☑/☐), page numbers, selection count, empty state displays

**Why?** The `msg_*` functions format complete messages with `[ERROR]`/`[WARN]` prefixes and
icons, meant for application messages. UI components need fine-grained control for interactive
displays without prefixes.

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
