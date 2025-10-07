# Component Field Requirements

## 🎯 **Always Required Fields**
These fields should be present in EVERY component.yml:

```yaml
name: "component-name"
description: "Brief description"
installMethod: "package"
platforms: ["macos", "linux"]
parallelSafe: true
critical: false
requires: []
provides: []
healthCheck: "command --version"
tags: [category]
```

## 📝 **Conditional Fields**
Only include these when actually needed:

### **For installMethod: "package"**
```yaml
packages:
  brew: "package-name"
  apt: "package-name"
  dnf: "package-name"
```

### **For installMethod: "script"**
```yaml
scriptUrl: "https://..."  # OR
gitUrl: "https://..."
targetDir: "$HOME/..."
depth: 1
```

### **When component has files**
```yaml
files: ["~/.config/app/"]
```

## ✅ **Example: Complete Component**

```yaml
name: example-tool
description: "Example development tool"
installMethod: "package"
packages:
  brew: "example-tool"
  apt: "example-tool"
  dnf: "example-tool"
platforms: ["macos", "linux"]
parallelSafe: true
critical: false
requires: ["curl"]
provides: ["build-tool"]
healthCheck: "example-tool --version"
tags: [development, build]
files: ["~/.config/example/"]
```

## ✅ **Example: Minimal Component**

```yaml
name: simple-tool
description: "Simple system utility"
installMethod: "package"
packages:
  brew: "simple-tool"
  apt: "simple-tool"
  dnf: "simple-tool"
platforms: ["macos", "linux"]
parallelSafe: true
critical: false
requires: []
provides: []
healthCheck: "simple-tool --version"
tags: [utility]
```
