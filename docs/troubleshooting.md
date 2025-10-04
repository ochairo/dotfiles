# Troubleshooting Guide

Common issues and solutions for the dotfiles management system.

## General Issues

### Installation Problems

#### Command not found: `dot`

**Problem**: The `dot` command is not recognized.

**Solutions**:

1. **Make the script executable**:

   ```bash
   chmod +x ./dot
   ```

2. **Use the full path**:

   ```bash
   ././dot help
   ```

3. **Add to PATH** (optional):

   ```bash
   export PATH="$PWD:$PATH"
   dot help
   ```

#### Permission denied errors

**Problem**: Getting permission errors during installation.

**Solutions**:

1. **Check file permissions**:

   ```bash
   ls -la ./dot
   # Should show executable permissions: -rwxr-xr-x
   ```

2. **For system-wide installations**, components may need sudo:

   ```bash
   # This is expected for system package managers
   dot install --only homebrew  # May prompt for sudo
   ```

3. **For user-space installations**, avoid sudo:

   ```bash
   # Install to user directories
   dot install --only nvim  # Should not need sudo
   ```

#### Components not found

**Problem**: `dot install --only component-name` says component not found.

**Solutions**:

1. **List available components**:

   ```bash
   dot help  # Shows available commands
   ls components/  # Shows available components
   ```

2. **Check component name spelling**:

   ```bash
   # Correct
   dot install --only nvim

   # Incorrect
   dot install --only neovim  # Wrong name
   ```

3. **Verify component structure**:

   ```bash
   # Component should have:
   ls components/nvim/
   # component.yml  install.sh
   ```

### Health Check Failures

#### Health check command not found

**Problem**: Health checks fail with "command not found".

**Solutions**:

1. **Install the component first**:

   ```bash
   dot install --only component-name
   dot health --only component-name
   ```

2. **Check if component installation succeeded**:

   ```bash
   dot status
   ```

3. **Manually verify installation**:

   ```bash
   # Check if the tool is actually installed
   command -v git
   which nvim
   ```

#### Health check returns wrong version

**Problem**: Health check detects old or wrong version.

**Solutions**:

1. **Check PATH order**:

   ```bash
   echo $PATH
   which tool-name
   ```

2. **Reload shell environment**:

   ```bash
   source ~/.zshrc
   # or
   exec zsh
   ```

3. **Reinstall component**:

   ```bash
   dot install --repeat --only component-name
   ```

### Symlink Issues

#### Symlink conflicts

**Problem**: Installation fails due to existing files.

**Error message**: `File exists at destination`

**Solutions**:

1. **Backup existing files**:

   ```bash
   mv ~/.vimrc ~/.vimrc.backup
   dot install --only vim
   ```

2. **Check what's at the destination**:

   ```bash
   ls -la ~/.vimrc
   # If it's already a symlink: lrwxr-xr-x
   # If it's a regular file: -rw-r--r--
   ```

3. **Use the status command to understand conflicts**:

   ```bash
   dot status
   ```

#### Broken symlinks

**Problem**: Symlinks point to non-existent files.

**Solutions**:

1. **Check symlink status**:

   ```bash
   dot status | grep MISSING
   ```

2. **Verify source files exist**:

   ```bash
   ls -la dotfiles/configs/.vimrc
   ```

3. **Recreate symlinks**:

   ```bash
   dot install --repeat --only component-name
   ```

### Package Manager Issues

#### Homebrew not found (macOS)

**Problem**: Component installation fails because Homebrew isn't installed.

**Solutions**:

1. **Install Homebrew first**:

   ```bash
   dot install --only homebrew
   ```

2. **Or install manually**:

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

#### apt/dnf not found (Linux)

**Problem**: Package manager not detected on Linux.

**Solutions**:

1. **Check your distribution**:

   ```bash
   cat /etc/os-release
   ```

2. **Install appropriate package manager support**:

   ```bash
   # For Ubuntu/Debian
   dot install --only apt-essentials

   # For Fedora/RHEL
   dot install --only dnf-essentials
   ```

## Platform-Specific Issues

### macOS Issues

#### Xcode Command Line Tools missing

**Problem**: Git or other tools fail to install.

**Solutions**:

1. **Install Command Line Tools**:

   ```bash
   xcode-select --install
   ```

2. **Verify installation**:

   ```bash
   xcode-select -p
   # Should show: /Applications/Xcode.app/Contents/Developer
   # or: /Library/Developer/CommandLineTools
   ```

#### Rosetta 2 issues (Apple Silicon)

**Problem**: x86_64 binaries don't work on M1/M2 Macs.

**Solutions**:

1. **Install Rosetta 2**:

   ```bash
   sudo softwareupdate --install-rosetta
   ```

2. **Use native ARM64 versions** when available:

   ```bash
   # Homebrew automatically handles this
   brew install tool-name
   ```

#### System Integrity Protection (SIP) issues

**Problem**: Cannot modify system directories.

**Solutions**:

1. **Use user directories** instead of system directories
2. **Check SIP status**:

   ```bash
   csrutil status
   ```

3. **Use user-space alternatives**:

   ```bash
   # Instead of /usr/local, use ~/.local
   export PATH="$HOME/.local/bin:$PATH"
   ```

### Linux Issues

#### sudo password prompts

**Problem**: Installation hangs waiting for sudo password.

**Solutions**:

1. **Run with sudo when needed**:

   ```bash
   sudo dot install --only system-essentials
   ```

2. **Configure passwordless sudo** (optional):

   ```bash
   sudo visudo
   # Add: your-username ALL=(ALL) NOPASSWD: ALL
   ```

#### Package manager differences

**Problem**: Component assumes wrong package manager.

**Solutions**:

1. **Check your package manager**:

   ```bash
   # Ubuntu/Debian
   which apt-get

   # Fedora/RHEL
   which dnf

   # Arch
   which pacman
   ```

2. **Modify component for your distro** or **create distro-specific variant**

#### Missing dependencies

**Problem**: Tools fail because dependencies aren't installed.

**Solutions**:

1. **Install system essentials first**:

   ```bash
   dot install --only system-essentials
   ```

2. **Check specific requirements**:

   ```bash
   dot doctor
   ```

## Component-Specific Issues

### Neovim Issues

#### Neovim config errors

**Problem**: Neovim shows errors on startup.

**Solutions**:

1. **Check Neovim version**:

   ```bash
   nvim --version
   # Should be 0.8.0 or higher
   ```

2. **Verify configuration symlink**:

   ```bash
   ls -la ~/.config/nvim
   # Should point to dotfiles/configs/.config/nvim
   ```

3. **Reset Neovim completely**:

   ```bash
   dot nvim-reset --force
   dot install --only nvim
   ```

4. **Check plugin installation**:

   ```bash
   nvim --headless +PackerSync +qall
   ```

#### LSP not working

**Problem**: Language Server Protocol features don't work.

**Solutions**:

1. **Check if language servers are installed**:

   ```bash
   which lua-language-server
   which pyright
   ```

2. **Install language servers**:

   ```bash
   # Via Mason in Neovim
   :MasonInstall lua-language-server pyright
   ```

3. **Check Neovim health**:

   ```bash
   nvim +checkhealth
   ```

### Shell Issues

#### Zsh configuration not loading

**Problem**: Shell customizations don't appear.

**Solutions**:

1. **Check default shell**:

   ```bash
   echo $SHELL
   # Should be /bin/zsh or /usr/bin/zsh
   ```

2. **Change default shell**:

   ```bash
   chsh -s $(which zsh)
   # Then restart terminal
   ```

3. **Check zsh configuration symlink**:

   ```bash
   ls -la ~/.zshrc
   # Should point to dotfiles config
   ```

4. **Source configuration manually**:

   ```bash
   source ~/.zshrc
   ```

#### Oh My Zsh not found

**Problem**: Zsh enhancements not working.

**Solutions**:

1. **Install Oh My Zsh**:

   ```bash
   dot install --only ohmyzsh
   ```

2. **Check installation**:

   ```bash
   ls -la ~/.oh-my-zsh
   ```

3. **Verify plugins**:

   ```bash
   dot plugins list
   ```

### Git Issues

#### Git authentication failures

**Problem**: Git operations fail with authentication errors.

**Solutions**:

1. **Check Git configuration**:

   ```bash
   git config --list
   ```

2. **Set up SSH keys**:

   ```bash
   ssh-keygen -t ed25519 -C "your-email@example.com"
   cat ~/.ssh/id_ed25519.pub
   # Add to GitHub/GitLab
   ```

3. **Test SSH connection**:

   ```bash
   ssh -T git@github.com
   ```

#### Git GPG signing issues

**Problem**: Git commits fail due to GPG signing.

**Solutions**:

1. **Install GPG tools**:

   ```bash
   dot install --only gpg_ssh
   ```

2. **Check GPG keys**:

   ```bash
   gpg --list-secret-keys
   ```

3. **Configure Git GPG**:

   ```bash
   git config --global gpg.program gpg
   git config --global user.signingkey YOUR_KEY_ID
   ```

## Development Issues

### Debugging Component Installation

#### Enable debug logging

```bash
DOTFILES_LOG_LEVEL=debug dot install --only component-name
```

#### Test component isolation

```bash
# Test in dry-run mode first
dot install --dry-run --only component-name

# Test with minimal selection
dot install --only system-essentials,component-name
```

#### Manual component testing

```bash
cd components/component-name
bash -x install.sh
```

### CI/CD Issues

#### GitHub Actions failing

**Problem**: CI pipeline fails on GitHub.

**Solutions**:

1. **Test locally first**:

   ```bash
   ./dot validate
   ```

2. **Check specific CI steps**:

   ```bash
   # Structure validation
   test -f ./dot && test -d commands && test -d core

   # Linting
   shellcheck **/*.sh

   # Format checking
   shfmt -d **/*.sh

   # Tests
   bats tests/
   ```

3. **Platform differences**:
   - Test on both macOS and Linux
   - Check for hardcoded paths
   - Verify package manager detection

#### Test failures

**Problem**: Bats tests fail locally.

**Solutions**:

1. **Check Bats installation**:

   ```bash
   bats --version
   ```

2. **Run tests individually**:

   ```bash
   bats tests/fs.bats
   bats tests/bats/00_verify_command.bats
   ```

3. **Debug test environment**:

   ```bash
   BATS_DEBUG=1 bats tests/specific-test.bats
   ```

## Performance Issues

### Slow installation

**Problem**: Component installation takes too long.

**Solutions**:

1. **Use parallel installation** (experimental):

   ```bash
   dot install --parallel
   ```

2. **Install only what you need**:

   ```bash
   dot install --only git,nvim,zsh
   ```

3. **Check network connectivity**:

   ```bash
   # Test package manager speed
   time brew install --dry-run some-package
   ```

### High memory usage

**Problem**: Installation uses too much memory.

**Solutions**:

1. **Install components individually**:

   ```bash
   for comp in git nvim zsh; do
       dot install --only "$comp"
   done
   ```

2. **Monitor memory usage**:

   ```bash
   # On macOS
   top -pid $(pgrep -f "dot install")

   # On Linux
   htop -p $(pgrep -f "dot install")
   ```

## Recovery Procedures

### Complete system reset

If everything breaks:

1. **Backup current state**:

   ```bash
   cp -r ~/.config ~/.config.backup
   cp ~/.zshrc ~/.zshrc.backup
   ```

2. **Remove all symlinks**:

   ```bash
   dot status | grep "^OK" | cut -f2 | xargs rm -f
   ```

3. **Clean reinstall**:

   ```bash
   dot install --only system-essentials
   dot install --only shell-basics
   # Add components incrementally
   ```

### Restore from backup

If you have backups:

1. **Find backup files**:

   ```bash
   find ~ -name "*.backup-*" -type f
   ```

2. **Restore specific files**:

   ```bash
   mv ~/.zshrc.backup-20240101 ~/.zshrc
   ```

3. **Verify restoration**:

   ```bash
   dot status
   ```

## Getting Help

### Diagnostic Information

When reporting issues, include:

1. **System information**:

   ```bash
   uname -a
   echo $SHELL
   echo $PATH
   ```

2. **Dotfiles status**:

   ```bash
   dot doctor --json
   dot status
   ```

3. **Error output**:

   ```bash
   DOTFILES_LOG_LEVEL=debug dot install --only problematic-component 2>&1
   ```

### Support Channels

1. **Check existing issues**: [GitHub Issues](https://github.com/user/dotfiles/issues)
2. **Read documentation**: `docs/` directory
3. **Create detailed issue**: Include diagnostic information
4. **Join discussions**: GitHub Discussions (if enabled)

### Creating Good Bug Reports

Include:

1. **Expected behavior**: What should happen
2. **Actual behavior**: What actually happens
3. **Steps to reproduce**: Exact commands run
4. **Environment**: OS, shell, versions
5. **Logs**: Debug output and error messages
6. **Workarounds**: Any temporary solutions found

Example bug report:

```markdown
**Expected Behavior**
The nvim component should install successfully and create symlinks.

**Actual Behavior**
Installation fails with "Permission denied" error.

**Steps to Reproduce**
1. `git clone dotfiles`
2. `cd dotfiles`
3. `./dot install --only nvim`

**Environment**
- OS: macOS 13.0
- Shell: zsh 5.8.1
- Homebrew: 3.6.0

**Error Output**
```

[ERROR] Permission denied: ~/.config/nvim

```

**Additional Context**
~/.config directory exists and is writable.
Works fine with other components.
```
