#!/usr/bin/env bash
# usage: dot doctor [--json]
# summary: Environment & health diagnostics (--json for structured output)
# group: core
set -euo pipefail

# All constants and paths are now provided by the dot script via environment variables
# shellcheck disable=SC1091
source "$CORE_DIR/bootstrap.sh"
core_require log registry selection

JSON=0
for a in "$@"; do
	case $a in
	--json) JSON=1 ;;
	-h | --help)
		grep '^# usage:' "$0" | sed 's/# usage: //'
		exit 0
		;;
	*) log_warn "Unknown flag $a" ;;
	esac
done

# Component inventory & critical presence
components=($(registry_list_components))
critical_missing=()
for c in "${components[@]}"; do
	if registry_is_critical "$c"; then
		# Heuristic: if component declares healthCheck and it fails -> mark missing
		hc=$(registry_health_check "$c" || true)
		if [[ -n $hc ]]; then
			if ! bash -c "$hc" >/dev/null 2>&1; then
				critical_missing+=("$c")
			fi
		fi
	fi
done

# Update check (lightweight fetch)
UPDATE_STATE="unknown"
CURRENT_REF=""
REMOTE_REF=""
if [[ -d "$PROJECT_ROOT/.git" ]]; then
	CURRENT_REF=$(git -C "$PROJECT_ROOT" rev-parse --short HEAD 2>/dev/null || true)
	branch=$(git -C "$PROJECT_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)
	git -C "$PROJECT_ROOT" fetch --quiet origin "$branch" || true
	REMOTE_REF=$(git -C "$PROJECT_ROOT" rev-parse --short "origin/$branch" 2>/dev/null || true)
	if [[ -n $CURRENT_REF && -n $REMOTE_REF ]]; then
		if [[ $CURRENT_REF == $REMOTE_REF ]]; then UPDATE_STATE="up-to-date"; else UPDATE_STATE="out-of-date"; fi
	fi
fi

last_selection=$(selection_load || true)

if [[ $JSON == 1 ]]; then
	printf '{'
	printf '"update":{"state":"%s","current":"%s","remote":"%s"},' "$UPDATE_STATE" "$CURRENT_REF" "$REMOTE_REF"
	printf '"critical":{"missing":['
	for i in "${!critical_missing[@]}"; do
		printf '%s"%s"' $([[ $i -gt 0 ]] && echo ',') "${critical_missing[$i]}"
	done
	printf ']},'
	printf '"selection":%s' "$(printf '%s' "$last_selection" | jq -R 'split(" ")|map(select(length>0))')"
	printf '}'
	echo
	exit 0
fi

log_info "Doctor Report"
log_info "Update: $UPDATE_STATE (local=$CURRENT_REF remote=$REMOTE_REF)"
if [[ ${#critical_missing[@]} -gt 0 ]]; then
	log_error "Critical components failing health: ${critical_missing[*]}"
else
	log_info "All critical components pass health checks"
fi
log_info "Last selection: ${last_selection:-<none>}"
[[ ${#critical_missing[@]} -gt 0 ]] && exit 2 || exit 0
