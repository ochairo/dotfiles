# Development Guide

Extending and maintaining the dotfiles management system.

## Getting Started

### Prerequisites

- **Bash 4.0+** or **Zsh 5.0+**
- **Git** for version control
- **Bats** for testing (install via package manager)
- **ShellCheck** for linting (recommended)
- **shfmt** for formatting (recommended)

### Development Setup

1. **Install development tools**:

   ```bash
   # macOS
   brew install shellcheck shfmt bats-core

   # Linux (Ubuntu/Debian)
   sudo apt-get install shellcheck bats
   curl -L "https://github.com/mvdan/sh/releases/latest/download/shfmt_v3.7.0_linux_amd64" -o /usr/local/bin/shfmt
   chmod +x /usr/local/bin/shfmt
   ```

2. **Run validation**:

   ```bash
   src/bin/dot validate
   ```

3. **Run tests**:

   ```bash
   bats tests/
   ```

## Project Structure

```bash
dotfiles/
├── .github/
│   └── workflows/ci.yml     # CI/CD pipeline
├── dot                      # Main CLI entry point (contains all constants)
├── src/                     # Dotfiles system functionality
│   ├── commands/            # Command implementations
│   │   ├── install.sh      # Installation command
│   │   ├── health.sh       # Health check command
│   │   └── ...             # Other commands
│   ├── core/               # Core library modules
│   │   ├── bootstrap.sh    # Module loading system
│   │   ├── log.sh         # Logging utilities
│   │   ├── registry.sh    # Component registry
│   │   └── ...            # Other core modules
│   ├── components/         # Component definitions
│   │   ├── git/           # Git component
│   │   ├── nvim/          # Neovim component
│   │   └── ...            # Other components
│   ├── configs/           # Configuration files
│   ├── resources/         # Static resources
│   └── state/             # Runtime state files
├── tests/                  # Test suite
│   ├── bats/              # Bats tests
│   └── test_helper.bash   # Test utilities
├── docs/                   # Documentation
└── README.md               # Main documentation
```

## Development Workflow

### 1. Issue Tracking

Before starting development:

1. Check existing issues on GitHub
2. Create an issue if one doesn't exist
3. Discuss the approach in the issue
4. Get approval for significant changes

### 2. Branch Strategy

Use descriptive branch names:

```bash
# Feature branches
git checkout -b feature/add-new-component
git checkout -b feature/improve-logging

# Bug fixes
git checkout -b fix/installation-error
git checkout -b fix/health-check-timeout

# Documentation
git checkout -b docs/update-api-reference
```

### 3. Development Process

1. **Create feature branch**:

   ```bash
   git checkout -b feature/my-feature
   ```

2. **Make changes**:
   - Follow coding standards
   - Add tests for new functionality
   - Update documentation

3. **Test locally**:

   ```bash
   src/bin/dot validate
   bats tests/
   ```

4. **Commit changes**:

   ```bash
   git add .
   git commit -m "feat: add new component support"
   ```

5. **Push and create PR**:

   ```bash
   git push origin feature/my-feature
   # Create pull request on GitHub
   ```

## Coding Standards

### Shell Script Guidelines

1. **Use strict mode**:

   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   ```

2. **Function naming**:

   ```bash
   # Use snake_case for functions
   function install_component() {
       # Implementation
   }
   ```

3. **Variable naming**:

   ```bash
   # Use UPPER_CASE for constants
   readonly DOTFILES_ROOT="/path/to/dotfiles"

   # Use lower_case for local variables
   local component_name="git"
   ```

4. **Error handling**:

   ```bash
   # Always check command success
   if ! command -v git >/dev/null 2>&1; then
       log_error "Git is required but not found"
   fi
   ```

5. **Quoting**:

   ```bash
   # Always quote variables
   local file_path="$HOME/.config/tool"

   # Quote command substitution
   local current_user="$(whoami)"
   ```

### Documentation Standards

1. **Function documentation**:

   ```bash
   # Brief description of function purpose
   # Arguments:
   #   $1 - component name
   #   $2 - installation directory
   # Returns:
   #   0 on success, 1 on error
   install_component() {
       # Implementation
   }
   ```

2. **Command documentation**:

   ```bash
   #!/usr/bin/env bash
   # usage: dot command [options]
   # summary: Brief description of command
   # group: command-group
   ```

3. **Component documentation**:

   ```yaml
   # component.yml
   name: "component-name"
   description: "Clear, concise description"
   ```

### Testing Standards

1. **Test organization**:

   ```bash
   # tests/component-name.bats
   #!/usr/bin/env bats

   load test_helper

   @test "component installs successfully" {
       # Test implementation
   }
   ```

2. **Test isolation**:

   ```bash
   setup() {
       # Test setup
       TEST_DIR="$BATS_TEST_TMPDIR/test"
       mkdir -p "$TEST_DIR"
   }

   teardown() {
       # Test cleanup
       rm -rf "$TEST_DIR"
   }
   ```

## Contributing Guidelines

### Pull Request Process

1. **Before submitting**:
   - Ensure all tests pass
   - Update documentation
   - Follow commit message format
   - Add changelog entry if needed

2. **PR description should include**:
   - Summary of changes
   - Issue references
   - Testing performed
   - Breaking changes (if any)

3. **Review process**:
   - Automated CI checks must pass
   - At least one maintainer approval
   - Address review feedback
   - Squash commits if requested

### Commit Message Format

Use conventional commit format:

```bash
type(scope): brief description

[optional body]

[optional footer]
```

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test additions/changes
- `chore`: Maintenance tasks

**Examples:**

```bash
feat(commands): add --parallel flag to install command

Add support for parallel component installation to reduce
installation time for independent components.

Closes #123
```

```bash
fix(health): handle missing health check commands gracefully

Previously, components with missing health check commands
would cause the health command to exit with an error.
Now it reports the issue and continues.

Fixes #456
```

## Creating New Commands

### Command Template

```bash
#!/usr/bin/env bash
# usage: dot new-command [--option] <argument>
# summary: Brief description of what this command does
# group: core

set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/core/bootstrap.sh"
core_require log

# Parse arguments
OPTION_FLAG=0
ARGUMENT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --option) OPTION_FLAG=1; shift;;
        -h|--help) grep -E '^# (usage|summary):' "$0" | sed 's/^# //'; exit 0;;
        -*) log_warn "Unknown option: $1"; shift;;
        *) ARGUMENT="$1"; shift;;
    esac
done

# Validate arguments
if [[ -z "$ARGUMENT" ]]; then
    log_error "Argument required"
fi

# Main logic
log_info "Executing new-command with argument: $ARGUMENT"

# Implementation here
```

### Command Guidelines

1. **Follow the template structure**
2. **Include usage and summary comments**
3. **Handle arguments consistently**
4. **Provide help with `-h/--help`**
5. **Use core modules for common functionality**
6. **Add appropriate logging**
7. **Handle errors gracefully**

## Creating New Components

### Component Development Process

1. **Plan the component**:
   - Define purpose and scope
   - Identify dependencies
   - Plan configuration files
   - Design health checks

2. **Create component structure**:

   ```bash
   mkdir components/my-tool
   cd components/my-tool
   ```

3. **Create metadata file**:

   ```yaml
   # component.yml
   name: "my-tool"
   description: "Description of my tool"
   version: "1.0.0"
   tags: [cli, utility]
   priority: 50

   health: "my-tool --version"

   install:
     commands:
       macos: ["brew install my-tool"]
       linux: ["sudo apt-get install my-tool"]
   ```

4. **Create installation script**:

   ```bash
   #!/usr/bin/env bash
   set -euo pipefail

   log_info "Installing $COMPONENT_NAME"

   # Check if already installed
   if os_has_command "my-tool"; then
       log_info "$COMPONENT_NAME already installed"
       exit 0
   fi

   # Platform-specific installation
   if os_is_macos; then
       brew install my-tool
   elif os_is_linux; then
       sudo apt-get install -y my-tool
   else
       log_error "Unsupported platform"
   fi

   log_info "$COMPONENT_NAME installation complete"
   ```

5. **Test the component**:

   ```bash
   # Test installation
   src/bin/dot install --dry-run --only my-tool
   src/bin/dot install --only my-tool

   # Test health check
   src/bin/dot health --only my-tool

   # Test status
   src/bin/dot status
   ```

### Component Best Practices

1. **Idempotency**: Safe to run multiple times
2. **Error handling**: Check prerequisites
3. **Platform support**: Handle OS differences
4. **Dependencies**: Declare explicitly
5. **Health checks**: Verify installation
6. **Documentation**: Clear descriptions
7. **Testing**: Test on target platforms

## Testing

### Test Structure

```bash
tests/
├── bats/                   # Integration tests
│   ├── 00_verify_command.bats
│   ├── 01_transactional_install.bats
│   └── 02_install_parallel_order.bats
├── fs.bats                 # Unit tests (legacy)
└── test_helper.bash        # Test utilities
```

### Writing Tests

1. **Use descriptive test names**:

   ```bash
   @test "install command creates symlinks correctly" {
       # Test implementation
   }
   ```

2. **Test both success and failure cases**:

   ```bash
   @test "install fails gracefully with missing dependencies" {
       # Test error conditions
   }
   ```

3. **Use test helpers**:

   ```bash
   load test_helper

   @test "component health check passes" {
       run_command "./dot health --only git"
       assert_success
       assert_output --partial "PASS"
   }
   ```

### Running Tests

```bash
# Run all tests
bats tests/

# Run specific test file
bats tests/bats/00_verify_command.bats

# Run with verbose output
bats --verbose-run tests/

# Run tests in docker (for Linux testing on macOS)
docker run --rm -v "$PWD:/workspace" -w /workspace ubuntu:latest bash -c "
    apt-get update && apt-get install -y bats
    bats tests/
"
```

## Debugging

### Debug Mode

Enable debug logging:

```bash
DOTFILES_LOG_LEVEL=debug ./dot install --only git
```

### Common Debugging Techniques

1. **Dry run mode**:

   ```bash
   ./dot install --dry-run --only component-name
   ```

2. **Component validation**:

   ```bash
   ./dot validate
   ```

3. **Health check debugging**:

   ```bash
   ./dot health --only component-name
   ```

4. **Status monitoring**:

   ```bash
   ./dot status --json | jq '.'
   ```

5. **Manual script execution**:

   ```bash
   cd components/component-name
   bash -x install.sh
   ```

## CI/CD

### GitHub Actions Workflow

The CI pipeline (`.github/workflows/ci.yml`) includes:

1. **Structure validation**
2. **Dependency installation**
3. **Shell script linting**
4. **Format checking**
5. **Test execution**
6. **Integration testing**

### Local CI Simulation

Run the same checks locally:

```bash
# Validation (includes structure, lint, format, tests)
./dot validate

# Individual steps
shellcheck **/*.sh
shfmt -d **/*.sh
bats tests/
```

## Release Process

### Version Management

1. **Update version numbers**:
   - Update component versions
   - Update documentation
   - Update changelog

2. **Create release branch**:

   ```bash
   git checkout -b release/v1.2.0
   ```

3. **Prepare release**:
   - Run full test suite
   - Update changelog
   - Tag release

4. **Create GitHub release**:
   - Create tag: `git tag v1.2.0`
   - Push tag: `git push origin v1.2.0`
   - Create release on GitHub

### Changelog Format

Follow [Keep a Changelog](https://keepachangelog.com/) format:

```markdown
# Changelog

## [1.2.0] - 2024-01-15

### Added
- New component for tool X
- Parallel installation support

### Changed
- Improved error messages
- Updated health check logic

### Fixed
- Fixed symlink creation on Linux
- Resolved dependency resolution bug

### Removed
- Deprecated legacy commands
```

## Troubleshooting Development Issues

### Common Issues

1. **Tests failing**:
   - Check Bats installation
   - Verify test dependencies
   - Run tests in isolation

2. **Linting errors**:
   - Install ShellCheck
   - Fix quoted variables
   - Handle error conditions

3. **Component not found**:
   - Check directory structure
   - Validate component.yml syntax
   - Verify component name matches directory

4. **Installation failures**:
   - Test component isolation
   - Check dependency declarations
   - Verify platform support

### Getting Help

1. **Check existing issues** on GitHub
2. **Read the documentation** in `docs/`
3. **Run diagnostics**: `./dot doctor`
4. **Ask in discussions** on GitHub
5. **Create an issue** with details

## Code Review Guidelines

### For Authors

1. **Self-review first**
2. **Test thoroughly**
3. **Update documentation**
4. **Follow commit conventions**
5. **Respond to feedback promptly**

### For Reviewers

1. **Be constructive**
2. **Focus on code quality**
3. **Check test coverage**
4. **Verify documentation**
5. **Test the changes**

### Review Checklist

- [ ] Code follows style guidelines
- [ ] Tests pass and cover new functionality
- [ ] Documentation is updated
- [ ] Commit messages follow convention
- [ ] No breaking changes (or properly documented)
- [ ] Performance impact considered
- [ ] Security implications reviewed
