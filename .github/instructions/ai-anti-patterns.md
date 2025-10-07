# Common AI Anti-Patterns to Avoid

## Code Generation Anti-Patterns

### 1. Creating Redundant Files Instead of Updating

AI creates new files instead of updating existing ones. For example, creating "component-updated.sh" when
"component.sh" already exists, or creating "config-new.yml" instead of editing "config.yml".

**What to Do Instead:**

Use edit tools to update existing files in place. If unsure, ask whether to update the existing file or create a new one.

### 2. Creating Workarounds Instead of Fixing Root Problems

AI generates code that works around an issue instead of addressing the underlying problem. For example,
trying multiple installation methods when a package fails instead of checking if the package manager is
properly configured.

**What to Do Instead:**

When something fails, first understand why it failed. Diagnose common root causes like missing tools or
configuration issues. Fix the underlying problem rather than working around it, and provide clear error
messages that help with debugging.
