# Component Schema: Installation Methods

## Overview

The component.yml schema supports multiple installation methods with intelligent fallback strategies.

## Installation Methods

### 1. `package` (Default)
Direct package manager installation.
```yaml
installMethod: "package"
packages:
  brew: "package-name"
  apt: "package-name"
  dnf: "package-name"
```

### 2. `cask`
Homebrew cask installation (macOS GUI apps).
```yaml
installMethod: "cask"
packageName: "app-name"
```

### 3. `script` (Hybrid with Fallback Chain)
**Most flexible method** - supports multiple fallback strategies:

**Fallback Chain Order:**
1. **Package managers first** (if `packages` defined)
2. **Script URL** (if `scriptUrl` defined)
3. **Git clone** (if `gitUrl` + `targetDir` defined)

**Example: Full hybrid configuration**
```yaml
installMethod: "script"
packages:
  brew: "pyenv"           # Try package manager first
scriptUrl: "https://pyenv.run"  # Fall back to script
gitUrl: "https://github.com/pyenv/pyenv.git"  # Fall back to git
targetDir: "$HOME/.pyenv"
depth: 1
```

**Example: Script-only**
```yaml
installMethod: "script"
scriptUrl: "https://get.sdkman.io"
```

**Example: Git-only**
```yaml
installMethod: "script"
gitUrl: "https://github.com/ohmyzsh/ohmyzsh.git"
targetDir: "$HOME/.oh-my-zsh"
depth: 1
```

### 4. `meta`
Meta-package that installs other components.

## Schema Fields for Script Method

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `scriptUrl` | string (URI) | URL to installation script | `"https://sh.rustup.rs"` |
| `gitUrl` | string (URI) | Git repository URL | `"https://github.com/pyenv/pyenv.git"` |
| `targetDir` | string | Target directory (supports env vars) | `"$HOME/.pyenv"` |
| `depth` | integer | Git clone depth (default: 1) | `1` |
| `packages` | object | Package fallbacks | `{brew: "pyenv"}` |

## Best Practices

1. **Use hybrid approach** for maximum compatibility:
   - Include `packages` for easy installation where available
   - Include `scriptUrl` or `gitUrl` for universal fallback

2. **Environment variable expansion** supported in `targetDir`:
   - `$HOME/.pyenv`
   - `${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/name`

3. **Shallow clones** by default (`depth: 1`) for faster installation

## Real-World Examples

### Version Manager (pyenv)
```yaml
name: pyenv
installMethod: "script"
packages:
  brew: "pyenv"                           # macOS users get easy install
scriptUrl: "https://pyenv.run"            # Universal script fallback
gitUrl: "https://github.com/pyenv/pyenv.git"  # Git fallback
targetDir: "$HOME/.pyenv"
```

### Zsh Plugin (autosuggestions)
```yaml
name: zsh-autosuggestions
installMethod: "script"
gitUrl: "https://github.com/zsh-users/zsh-autosuggestions"
targetDir: "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
depth: 1
```

### Framework (Oh My Zsh)
```yaml
name: ohmyzsh
installMethod: "script"
scriptUrl: "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
gitUrl: "https://github.com/ohmyzsh/ohmyzsh.git"
targetDir: "$HOME/.oh-my-zsh"
```

This hybrid approach maximizes compatibility while providing graceful fallbacks across different platforms and installation preferences.
