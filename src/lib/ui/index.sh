#!/usr/bin/env bash
# index.sh - Load all user interface utilities
# Source this file to get all user interface utilities at once

USERINTERFACES_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# Load user interaction functions
source "${USERINTERFACES_LIB_DIR}/input.sh"
source "${USERINTERFACES_LIB_DIR}/ansi.sh"
# ui_constants.sh removed (duplicate of constants/constants.sh)

# Phase 2+ extracted modules (constants, layout, components)
if [[ -f "${USERINTERFACES_LIB_DIR}/constants/constants.sh" ]]; then
	source "${USERINTERFACES_LIB_DIR}/constants/constants.sh"
fi
if [[ -f "${USERINTERFACES_LIB_DIR}/env/env.sh" ]]; then
	source "${USERINTERFACES_LIB_DIR}/env/env.sh"
fi
if [[ -f "${USERINTERFACES_LIB_DIR}/env/config.sh" ]]; then
	source "${USERINTERFACES_LIB_DIR}/env/config.sh"
fi
if [[ -f "${USERINTERFACES_LIB_DIR}/layout/layout.sh" ]]; then
	source "${USERINTERFACES_LIB_DIR}/layout/layout.sh"
fi
if [[ -f "${USERINTERFACES_LIB_DIR}/components/options/options.sh" ]]; then
	source "${USERINTERFACES_LIB_DIR}/components/options/options.sh"
fi
if [[ -f "${USERINTERFACES_LIB_DIR}/components/error/error.sh" ]]; then
	source "${USERINTERFACES_LIB_DIR}/components/error/error.sh"
fi
if [[ -f "${USERINTERFACES_LIB_DIR}/components/footer/footer.sh" ]]; then
	source "${USERINTERFACES_LIB_DIR}/components/footer/footer.sh"
fi
if [[ -f "${USERINTERFACES_LIB_DIR}/components/header/header.sh" ]]; then
	source "${USERINTERFACES_LIB_DIR}/components/header/header.sh"
fi
if [[ -f "${USERINTERFACES_LIB_DIR}/components/fixed_header/fixed_header.sh" ]]; then
	source "${USERINTERFACES_LIB_DIR}/components/fixed_header/fixed_header.sh"
fi
if [[ -f "${USERINTERFACES_LIB_DIR}/components/pageinfo/pageinfo.sh" ]]; then
	source "${USERINTERFACES_LIB_DIR}/components/pageinfo/pageinfo.sh"
fi
if [[ -f "${USERINTERFACES_LIB_DIR}/multiselect/state.sh" ]]; then
	source "${USERINTERFACES_LIB_DIR}/multiselect/state.sh"
fi
if [[ -f "${USERINTERFACES_LIB_DIR}/multiselect/handlers.sh" ]]; then
	source "${USERINTERFACES_LIB_DIR}/multiselect/handlers.sh"
fi
if [[ -f "${USERINTERFACES_LIB_DIR}/session/session.sh" ]]; then
	source "${USERINTERFACES_LIB_DIR}/session/session.sh"
fi

source "${USERINTERFACES_LIB_DIR}/pagination.sh"
source "${USERINTERFACES_LIB_DIR}/filter.sh"
## Removed legacy modules: ui_session.sh, ui_renderer.sh, ui_constants.sh, ui_fixed_header.sh
source "${USERINTERFACES_LIB_DIR}/select/ui_select.sh"
source "${USERINTERFACES_LIB_DIR}/multiselect/ui_multiselect.sh"
