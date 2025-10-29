#!/usr/bin/env bash
# component_install.sh - Per-component installation service logic
# Layering:
#   CLI command:  src/cli/commands/install.sh  (orchestrates selection, ordering, health summary)
#   Service:      this file (executes a single component install based on metadata)
#
# Supported installMethod:
#   package | script (current)
#   git, binary (planned placeholders)
#
# This name avoids confusion with the CLI command file also named install.sh.

if [[ -n "${DOTFILES_INSTALL_SERVICE_LOADED:-}" ]]; then
  return 0
fi
DOTFILES_INSTALL_SERVICE_LOADED=1
readonly DOTFILES_INSTALL_SERVICE_LOADED

components_install() {
  local comp="$1"
  if [[ -z "$comp" ]]; then
  msg_error "components_install: component name required"
    return 1
  fi
  if ! command -v os_platform >/dev/null 2>&1; then
  msg_error "components_install: os_platform not available (core not loaded?)"
    return 1
  fi
  local platform method pm pkg url hc
  platform=$(os_platform 2>/dev/null || echo macos)
  method=$(components_platform_field "$comp" "$platform" installMethod 2>/dev/null || echo "")
  if [[ -z "$method" ]]; then
  msg_warn "No installMethod declared for $comp on $platform (skipping)"
    return 0
  fi
  hc=$(components_health_check "$comp" 2>/dev/null || echo "")
  if [[ -n ${hc// /} ]]; then
    if eval "$hc" >/dev/null 2>&1; then
  msg_info "Already healthy (skipping install): $comp"
      return 0
    fi
  fi
  case "$method" in
    package)
      pm=$(components_platform_field "$comp" "$platform" packageManager 2>/dev/null || echo "")
      pkg=$(components_platform_field "$comp" "$platform" packageName 2>/dev/null || echo "$comp")
      if [[ -z "$pm" ]]; then
  msg_error "packageManager missing for $comp ($platform)"
        return 1
      fi
      if command -v "$pkg" >/dev/null 2>&1; then
  msg_info "Binary present (likely installed): $comp ($pkg)"
        return 0
      fi
      if [[ ${DRY_RUN:-0} == 1 ]]; then
  msg_info "[dry-run] Would install $pkg via $pm"
        return 0
      fi
      case "$pm" in
        brew)
          if ! command -v brew >/dev/null 2>&1; then
            msg_error "brew not found (ensure 'homebrew' component installed first)"
            return 1
          fi
          brew install "$pkg" || return 1 ;;
        apt|apt-get)
          if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update -y && sudo apt-get install -y "$pkg" || return 1
          else
            msg_error "apt-get not available for $comp"; return 1
          fi ;;
        dnf) sudo dnf install -y "$pkg" || return 1 ;;
        yay) yay -S --noconfirm "$pkg" || return 1 ;;
  *) msg_warn "Unsupported package manager '$pm' for $comp"; return 1 ;;
      esac
      ;;
    script)
      url=$(components_platform_field "$comp" "$platform" scriptUrl 2>/dev/null || echo "")
      if [[ -z "$url" ]]; then
  msg_error "scriptUrl missing for $comp ($platform)"; return 1
      fi
      if [[ ${DRY_RUN:-0} == 1 ]]; then
  msg_info "[dry-run] Would execute install script for $comp: $url"; return 0
      fi
      if ! command -v curl >/dev/null 2>&1; then
  msg_error "curl required to fetch install script for $comp"; return 1
      fi
      curl -fsSL "$url" | bash || return 1
      ;;
    git)
  msg_warn "git installMethod not yet implemented for $comp"; return 1 ;;
    binary)
  msg_warn "binary installMethod not yet implemented for $comp"; return 1 ;;
    *)
  msg_warn "Unsupported installMethod '$method' for $comp"; return 1 ;;
  esac
  return 0
}

install_component() { components_install "$@"; }

export -f components_install install_component
