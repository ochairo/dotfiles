#!/usr/bin/env bash
# install.sh - Component installation service
# Provides components_install which reads component metadata (component.yml)
# and performs installation based on platform-specific fields.
#
# Supported installMethod values (initial):
#   package  - Uses a package manager (brew, apt, apt-get, dnf, yay)
#   script   - Fetches and executes an install script (scriptUrl)
#   git      - (TODO) Clone a git repository
#   binary   - (TODO) Download and place a binary in PATH
#
# The function is bash 3.2+ compatible.

# Prevent double load (bash 3.2 compatible)
if [[ -n "${DOTFILES_INSTALL_SERVICE_LOADED:-}" ]]; then
  return 0
fi
DOTFILES_INSTALL_SERVICE_LOADED=1
readonly DOTFILES_INSTALL_SERVICE_LOADED

# components_install <component>
# Returns 0 on success, non-zero on failure.
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

  local platform method pm pkg url
  platform=$(os_platform 2>/dev/null || echo macos)

  method=$(components_platform_field "$comp" "$platform" installMethod 2>/dev/null || echo "")
  if [[ -z "$method" ]]; then
  msg_warn "No installMethod declared for $comp on $platform (skipping)"
    return 0
  fi

  # If a health check exists and already passes, skip early (more reliable than pkg name)
  local hc
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
      # Fallback command existence check (after health check attempt above)
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
          brew install "$pkg" || return 1
          ;;
        apt|apt-get)
          if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update -y && sudo apt-get install -y "$pkg" || return 1
          else
            msg_error "apt-get not available for $comp"
            return 1
          fi
          ;;
        dnf)
          sudo dnf install -y "$pkg" || return 1
          ;;
        yay)
          yay -S --noconfirm "$pkg" || return 1
          ;;
        *)
          msg_warn "Unsupported package manager '$pm' for $comp"
          return 1
          ;;
      esac
      ;;
    script)
      url=$(components_platform_field "$comp" "$platform" scriptUrl 2>/dev/null || echo "")
      if [[ -z "$url" ]]; then
  msg_error "scriptUrl missing for $comp ($platform)"
        return 1
      fi
      if [[ ${DRY_RUN:-0} == 1 ]]; then
  msg_info "[dry-run] Would execute install script for $comp: $url"
        return 0
      fi
      if ! command -v curl >/dev/null 2>&1; then
  msg_error "curl required to fetch install script for $comp"
        return 1
      fi
      curl -fsSL "$url" | bash || return 1
      ;;
    git)
      # Placeholder for future git clone logic
  msg_warn "git installMethod not yet implemented for $comp"
      return 1
      ;;
    binary)
  msg_warn "binary installMethod not yet implemented for $comp"
      return 1
      ;;
    *)
  msg_warn "Unsupported installMethod '$method' for $comp"
      return 1
      ;;
  esac

  return 0
}

export -f components_install

# Backwards-compatible name expected by older code / docs
install_component() { components_install "$@"; }
export -f install_component
