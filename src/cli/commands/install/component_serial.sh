#!/usr/bin/env bash
function run_component_serial() {
  local comp=$1
  local component_yml="$COMPONENTS_DIR/$comp/component.yml"
  if [[ -f "$component_yml" ]]; then
      msg_info "Installing: $comp"
    if ! install_component "$comp"; then
      msg_error "Component failed: $comp"
      if declare -F registry_is_critical >/dev/null 2>&1 && registry_is_critical "$comp"; then return 2; fi
    fi
    # Always attempt postInstall block (even if already healthy) to ensure config linking
    if declare -F os_platform >/dev/null 2>&1; then
      local _platform; _platform=$(os_platform 2>/dev/null || echo macos)
      if declare -F components_platform_block_field >/dev/null 2>&1; then
        local _post; _post=$(components_platform_block_field "$comp" "$_platform" postInstall || true)
        if [[ -n ${_post// /} ]]; then
          if [[ ${DRY_RUN:-0} == 1 ]]; then
            msg_info "[dry-run] Would run postInstall for $comp"
          else
            msg_dim "Running postInstall for $comp"
            # shellcheck disable=SC2154
            eval "$_post" || msg_warn "postInstall script returned non-zero for $comp"
          fi
        fi
      fi
      # Platform / generic script discovery (executed after inline YAML block)
      local comp_dir platform_script generic_script
      comp_dir="${COMPONENTS_DIR}/$comp"
      platform_script="${comp_dir}/${_platform}-post-install.sh"
      generic_script="${comp_dir}/post-install.sh"
      if [[ ${DRY_RUN:-0} == 1 ]]; then
        if [[ -f "$platform_script" ]]; then
          msg_info "[dry-run] Would source $platform_script"
        elif [[ -f "$generic_script" ]]; then
          msg_info "[dry-run] Would source $generic_script"
        fi
      else
        if [[ -f "$platform_script" ]]; then
          msg_dim "Executing platform script: ${platform_script##*/}"
          # shellcheck disable=SC1090
          if ! source "$platform_script"; then msg_warn "Platform post-install failed: $comp"; fi
        elif [[ -f "$generic_script" ]]; then
          msg_dim "Executing generic post-install script for $comp"
          # shellcheck disable=SC1090
          if ! source "$generic_script"; then msg_warn "Generic post-install failed: $comp"; fi
        fi
      fi
    fi
    local hc; hc=$(registry_health_check "$comp" || true)
    if [[ -n ${hc// /} ]]; then
      if components_check_health "$comp"; then
        _HEALTH_STATUS[$comp]=pass
        _HEALTH_PASSES=$((_HEALTH_PASSES + 1))
        msg_success "Health check passed: $comp"
      else
        _HEALTH_STATUS[$comp]=fail
        _HEALTH_FAILS=$((_HEALTH_FAILS + 1))
        if declare -F registry_is_critical >/dev/null 2>&1 && registry_is_critical "$comp"; then
          msg_error "Health check failed (critical): $comp"
          return 2
        else
          msg_warn "Health check failed (non-critical): $comp (continuing)"
        fi
      fi
    fi
  else
      msg_warn "No YAML definition for $comp (skipping)"
  fi
}
export -f run_component_serial
