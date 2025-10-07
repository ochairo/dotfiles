# Component Schema Field Order

This document defines the standard field order for `component.yml` files to ensure consistency and readability across all components.

## 📋 **Standard Field Order**

### **1. Identity & Core (Required/Primary)**
```yaml
name: "component-name"
description: "Brief description of what this component provides"
```

### **2. Installation Configuration**
```yaml
installMethod: "package"  # package, script, cask, meta
packages:                 # For installMethod: package
  brew: "package-name"
  apt: "package-name"
  dnf: "package-name"
scriptUrl: "https://..."  # For installMethod: script
gitUrl: "https://..."     # For installMethod: script (git clone)
targetDir: "$HOME/..."    # For git clones
depth: 1                  # For git clones
```

### **3. System Compatibility**
```yaml
platforms: ["macos", "linux"]
```

### **4. Component Behavior**
```yaml
parallelSafe: true        # Can install in parallel
critical: false           # Install priority
```

### **5. Dependencies & Relationships**
```yaml
requires: ["dependency1", "dependency2"]
provides: ["capability1", "capability2"]
```

### **6. Verification**
```yaml
healthCheck: "command --version"
```

### **7. Metadata & Organization**
```yaml
tags: [category, type]
```

### **8. File Management (Optional)**
```yaml
files: ["~/.config/app/"]
```

### **9. Legacy/Compatibility (Deprecated)**
```yaml
command: "actual-command"     # Use healthCheck instead
packageName: "package"        # Use packages instead
```

## ✅ **Complete Example**

```yaml
name: example-tool
description: "Example tool for demonstration"
installMethod: "package"
packages:
  brew: "example-tool"
  apt: "example-tool"
  dnf: "example-tool"
platforms: ["macos", "linux"]
parallelSafe: true
critical: false
requires: ["curl", "gcc"]
provides: ["build-tool"]
healthCheck: "example-tool --version"
tags: [development, build]
files: ["~/.config/example/"]
```

## 🎯 **Benefits of This Order**

1. **Identity first** - Most important information at the top
2. **Installation next** - Core functionality details
3. **Compatibility** - Platform requirements
4. **Behavior** - How it installs (parallel, critical)
5. **Dependencies** - What it needs and provides
6. **Verification** - How to test it works
7. **Metadata** - Classification and organization
8. **Optional fields** - Less critical information last
9. **Legacy fields** - Deprecated items at bottom
