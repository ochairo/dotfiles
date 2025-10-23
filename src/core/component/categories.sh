#!/usr/bin/env bash
# Component categorization and metadata
# Provides functions to get component categories and related information

# Component to category mapping
declare -gA COMPONENT_CATEGORY=(
  # Shell
  ["zsh"]="shell"
  ["ohmyzsh"]="shell"
  ["starship"]="shell"
  ["wezterm"]="shell"
  ["zellij"]="shell"
  ["shell-config"]="shell"
  ["zsh-plugins"]="shell"
  ["zsh-autosuggestions"]="shell"
  ["zsh-completions"]="shell"
  ["fast-syntax-highlighting"]="shell"
  ["fzf-tab"]="shell"

  # Editor
  ["neovim"]="editor"
  ["tree-sitter"]="editor"

  # Git
  ["git"]="git"
  ["gh"]="git"
  ["gpg-ssh"]="git"

  # Languages
  ["pyenv"]="languages"
  ["goenv"]="languages"
  ["rustup"]="languages"
  ["fnm"]="languages"
  ["rbenv"]="languages"
  ["sdkman"]="languages"
  ["pipx"]="languages"
  ["uv"]="languages"
  ["jupyterlab"]="languages"

  # CLI Tools
  ["ripgrep"]="cli"
  ["fd"]="cli"
  ["bat"]="cli"
  ["eza"]="cli"
  ["jq"]="cli"
  ["glow"]="cli"
  ["httpie"]="cli"
  ["wget"]="cli"
  ["curl"]="cli"
  ["unzip"]="cli"
  ["gcc"]="cli"
  ["zstd"]="cli"
  ["fzf"]="cli"

  # DevOps
  ["podman"]="devops"
  ["podman-compose"]="devops"
  ["lima"]="devops"
  ["lazydocker"]="devops"

  # Cloud
  ["azure-cli"]="cloud"
  ["ollama"]="cloud"
  ["huggingface"]="cloud"

  # Productivity
  ["tealdeer"]="productivity"
  ["direnv"]="productivity"
  ["dust"]="productivity"
  ["btop"]="productivity"
  ["dircolors"]="productivity"

  # System
  ["fonts"]="system"
  ["homebrew"]="system"
  ["apt-get"]="system"
  ["dnf"]="system"
)

# Category icons
declare -gA CATEGORY_ICONS=(
  ["shell"]="🐚"
  ["editor"]="📝"
  ["git"]="🔀"
  ["languages"]="⚙️ "
  ["cli"]="⚡"
  ["devops"]="🐳"
  ["cloud"]="☁️ "
  ["productivity"]="🚀"
  ["system"]="🔧"
)

# Get category for a component
# Args: component_name
# Returns: category name or "unknown"
categories_get_category() {
  local component="${1}"
  echo "${COMPONENT_CATEGORY[$component]:-unknown}"
}

# Get icon for a category
# Args: category_name
# Returns: emoji icon or 📦 as default
categories_get_icon() {
  local category="${1}"
  echo "${CATEGORY_ICONS[$category]:-📦}"
}

# Get all components sorted alphabetically
# Returns: array of component names
categories_get_all_components() {
  local all_components=()
  for component in "${!COMPONENT_CATEGORY[@]}"; do
    all_components+=("$component")
  done

  # Sort alphabetically
  mapfile -t all_components < <(sort <<<"${all_components[*]}")

  printf "%s\n" "${all_components[@]}"
}

# Get components by category
# Args: category_name
# Returns: space-separated list of components
categories_get_by_category() {
  local target_category="${1}"
  local components=()

  for component in "${!COMPONENT_CATEGORY[@]}"; do
    if [[ "${COMPONENT_CATEGORY[$component]}" == "$target_category" ]]; then
      components+=("$component")
    fi
  done

  # Sort alphabetically
  mapfile -t components < <(sort <<<"${components[*]}")

  printf "%s " "${components[@]}"
}

# Count total components
# Returns: number of components
categories_count_total() {
  echo "${#COMPONENT_CATEGORY[@]}"
}

# Count components in a category
# Args: category_name
# Returns: number of components
categories_count_by_category() {
  local category="${1}"
  local count=0

  for comp_category in "${COMPONENT_CATEGORY[@]}"; do
    [[ "$comp_category" == "$category" ]] && ((count++))
  done

  echo "$count"
}

# Get all unique categories
# Returns: sorted list of category names
categories_get_all_categories() {
  local categories=()
  for category in "${COMPONENT_CATEGORY[@]}"; do
    # Add to array if not already present
    if [[ ! " ${categories[*]} " =~ \ ${category}\  ]]; then
      categories+=("$category")
    fi
  done

  # Sort alphabetically
  mapfile -t categories < <(sort <<<"${categories[*]}")

  printf "%s\n" "${categories[@]}"
}
