# Test Suite

Comprehensive tests for the dotfiles management system.

## Test Files

- **`lib_primitives.bats`** - Tests for `src2/lib/primitives/` (msg, arrays, strings, validation, files, errors)
- **`lib_systemdetections.bats`** - Tests for `src2/lib/utilities/systemdetections/` (os, packages, commands, term, env)
- **`core_modules.bats`** - Tests for `src2/core/` (ledger, register, linker, resolver)
- **`cli_integration.bats`** - Integration tests for `src2/cli/bin/dot`

## Running Tests

### Install bats

**macOS:**
```bash
brew install bats-core
```

**Ubuntu/Debian:**
```bash
sudo apt-get install bats
```

**From source:**
```bash
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local
```

### Run all tests

```bash
./tests/run_tests.sh
```

### Run specific test file

```bash
./tests/run_tests.sh lib_primitives.bats
```

Or directly with bats:
```bash
bats tests/lib_primitives.bats
```

### Run specific test

```bash
bats tests/lib_primitives.bats --filter "msg_info"
```

## Test Coverage

### Library Tests (src2/lib/)

- ✅ Message printing (msg_info, msg_success, msg_warn, msg_error)
- ✅ Array operations (contains, join)
- ✅ String operations (trim, lower, upper, contains)
- ✅ Validation (not_empty, email)
- ✅ File operations (exists, is_readable)
- ✅ OS detection (os_detect, os_is_macos, os_is_linux)
- ✅ Package manager detection (pkg_detect)
- ✅ Command detection (cmd_exists)
- ✅ Terminal capabilities (supports_color, width, height)
- ✅ Environment variables (env_has_var, env_get)

### Core Tests (src2/core/)

- ✅ Ledger initialization (ledger_init)
- ✅ Ledger entries (ledger_add, ledger_has, ledger_entries)
- ✅ Component registry (components directory structure)
- ✅ Module loading (index.sh)

### CLI Tests (src2/cli/)

- ✅ Version command (--version, -v)
- ✅ Help command (--help, -h)
- ✅ Error handling (invalid commands)
- ✅ Command discovery (diagnostic, component, maintenance)
- ✅ Path resolution (DOTFILES_ROOT, LIB_DIR, CORE_DIR)
- ✅ Library loading (lib/index.sh, core/index.sh)
- ✅ Environment variables (DOTFILES_DEBUG, DOTFILES_LEDGER)

## Writing New Tests

### Test File Structure

```bash
#!/usr/bin/env bats
# Description of test file

setup() {
  # Run before each test
  export DOTFILES_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  source "$DOTFILES_ROOT/src2/lib/index.sh"
}

teardown() {
  # Run after each test (optional)
  # Cleanup temp files
}

@test "description of what is being tested" {
  run command_to_test
  [ "$status" -eq 0 ]
  [[ "$output" == *"expected output"* ]]
}
```

### Best Practices

1. **Isolation** - Each test should be independent
2. **Cleanup** - Use `teardown()` to clean up temp files
3. **Clear names** - Test names should describe what they test
4. **Assertions** - Use clear assertions (`[ "$status" -eq 0 ]`)
5. **Output checks** - Verify both exit code and output when needed

### Common Assertions

```bash
# Exit code
[ "$status" -eq 0 ]          # Success
[ "$status" -eq 1 ]          # Failure

# Output matching
[[ "$output" == *"text"* ]]  # Contains text
[[ "$output" =~ pattern ]]   # Matches regex

# File checks
[ -f "$file" ]               # File exists
[ -d "$dir" ]                # Directory exists
[ -x "$file" ]               # File is executable

# String comparisons
[ "$var" = "value" ]         # Exact match
[ -n "$var" ]                # Not empty
[ -z "$var" ]                # Empty
```

## CI Integration

These tests can be run in CI/CD pipelines:

```yaml
# GitHub Actions example
- name: Run tests
  run: ./tests/run_tests.sh
```

## Troubleshooting

### Tests fail to find files

Make sure `DOTFILES_ROOT` is set correctly in the test `setup()` function.

### Permission errors

Ensure test runner is executable:
```bash
chmod +x tests/run_tests.sh
```

### bats command not found

Install bats (see "Install bats" section above).
