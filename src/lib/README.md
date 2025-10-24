# Library Architecture

Reusable shell library for building CLIs and tools. Bash 3.2+ compatible (macOS/Linux).

## Structure

```text
src/lib/
├── colors.sh              # Color constants (C_RED, C_GREEN, etc.)
├── primitives/            # Basic operations (no business logic)
│   ├── msg.sh            # Message printing (msg_info, msg_error, etc.)
│   ├── arrays.sh         # Array utilities
│   ├── strings.sh        # String manipulation
│   └── errors.sh         # Error handling
├── userinterfaces/        # Interactive UI components
│   ├── select.sh         # Single-select menu
│   ├── multiselect.sh    # Multi-select with checkboxes
│   └── input.sh          # User input (confirm, text, number)
└── utilities/             # Business logic operations
    ├── files.sh          # File operations (backup, copy, move)
    ├── validation.sh     # Input validation
    ├── filesystem.sh     # Directory and PATH management
    ├── download.sh       # HTTP downloads and extraction
    ├── retry.sh          # Retry logic with backoff
    ├── symlinks.sh       # Symlink operations
    ├── parallel.sh       # Parallel execution
    ├── transactional.sh  # Transaction management
    └── systemdetections/ # OS, environment detection
```

## Dependency Hierarchy

```text
colors.sh → primitives/ → userinterfaces/ + utilities/
```

- **Primitives**: Basic operations, no business logic (msg, arrays, strings)
- **Utilities**: Higher-level operations with business logic (files, validation)
- **UI**: Interactive components using primitives

## Message Primitives

Always use `msg_*` functions for user-facing messages (never raw `echo` for errors/warnings):

```bash
msg_info "Installing..."       # [INFO] blue icon
msg_error "Failed!"            # [ERROR] red icon
msg_warn "Deprecated"          # [WARN] yellow icon
msg_success "Done!"            # [SUCCESS] green icon
msg_dim "Status"              # Dimmed text, no prefix
```

**Output Streams:**

- **stdout**: Function return values (`echo "$result"`)
- **stderr**: User messages (`msg_*` functions)

## Usage

```bash
# Load modules
source "${DOTFILES_ROOT}/src/lib/colors.sh"
source "${DOTFILES_ROOT}/src/lib/primitives/msg.sh"

# Or load all at once
source "${DOTFILES_ROOT}/src/lib/primitives/index.sh"
source "${DOTFILES_ROOT}/src/lib/utilities/index.sh"

# Use primitives
msg_info "Starting..."
msg_success "Complete!"

# Use utilities
file_backup "/etc/config"
if validate_file_exists "/etc/config"; then
    msg_success "Config found"
fi

# Use UI
choice=$(ui_select "Choose:" "Option 1" "Option 2")
if ui_confirm "Continue?"; then
    msg_info "Proceeding..."
fi
```

## Compatibility

Bash 3.2+ compatible. Avoid bash 4+ features:

```bash
# ❌ Bad (bash 4+)
local lower="${var,,}"

# ✅ Good (bash 3.2+)
local lower=$(echo "$var" | tr '[:upper:]' '[:lower:]')
```
