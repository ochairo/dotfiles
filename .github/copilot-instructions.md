````instructions
# GitHub Copilot Instructions

## Core Principles

### SOLID Principles

- **Single Responsibility**: Each module/function has one clear purpose
- **Open/Closed**: Extend via composition, not modification
- **Liskov Substitution**: Subtypes must be substitutable for base types
- **Interface Segregation**: Small, focused interfaces over large ones
- **Dependency Inversion**: Depend on abstractions, not concrete implementations

### Code Quality

- **DRY** (Don't Repeat Yourself): Extract common logic into reusable functions
- **KISS** (Keep It Simple): Prefer clarity over cleverness
- **120 Lines Per File**: Split files when exceeding 120 lines
  - Create logical directory structure
  - Group related functions into modules
  - Use clear, descriptive filenames

### File Organization

When a file exceeds 120 lines:

```text
# Before (monolithic)
component.sh (200 lines)

# After (modular)
component/
├── parser.sh       # YAML parsing (80 lines)
├── validator.sh    # Validation logic (70 lines)
└── installer.sh    # Installation (50 lines)
```

## Project-Specific Rules

### Shell Scripts (Bash 3.2+ compatible)
- Use `set -euo pipefail` for safety
- Never use `echo` for user messages (use `log_*` functions)
- Use `return 1` not `exit` in sourced scripts
- Shellcheck-compliant code required
- 2-space indentation

### Component Architecture

```yaml
name: tool-name              # Lowercase, hyphenated
description: "Brief description"
tags: [category]
parallelSafe: true|false
critical: false
healthCheck: "command -v tool >/dev/null 2>&1"
requires: []
provides: []

platforms:
  macos:
    installMethod: package
    packageManager: brew
    packageName: tool-name
```

### Logging Pattern

```bash
# Always use log functions
log_info "Message"       # Informational
log_warn "Warning"       # Warning
log_error "Error"        # Error
log_success "Done"       # Success
log_debug "Details"      # Debug (only if DOTFILES_DEBUG=1)
```

### Cross-Platform Pattern

```bash
if [[ "$(uname)" == "Darwin" ]]; then
  # macOS
elif [[ "$(uname)" == "Linux" ]]; then
  # Linux
fi
```

### Error Handling

```bash
function do_something() {
  local param="${1:-}"
  [[ -z "$param" ]] && log_error "Parameter required" && return 1

  if ! command_that_might_fail; then
    log_error "Operation failed"
    return 1
  fi

  log_success "Operation complete"
  return 0
}
```

## Security Rules

**Never commit:**
- API keys, tokens, passwords
- SSH keys, certificates
- Personal emails, hostnames
- `.env` files with secrets

**Always:**
- Use configuration templates
- Sanitize user inputs
- Validate file paths
- Check command exit codes

## AI Assistant Checklist

When suggesting code:
- [ ] Follows SOLID principles
- [ ] No code duplication (DRY)
- [ ] File under 120 lines (split if needed)
- [ ] Uses core libraries (don't reinvent)
- [ ] Proper error handling and logging
- [ ] Cross-platform compatible
- [ ] Shellcheck-compliant
- [ ] Includes health checks (for components)
- [ ] Documented if adding new patterns

## Reference
- Examples: See `src/components/*` for patterns
- Core libs: `src/core/` for reusable functions
- Detailed docs: `.github/docs/` (if structure exceeds 100 lines, reference external docs)
````
