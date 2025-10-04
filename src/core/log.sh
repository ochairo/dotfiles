#!/usr/bin/env bash
# log.sh (scaffold) - will later replace utils/messenger.sh with JSON + levels.

: "${DOTFILES_LOG_LEVEL:=INFO}"
: "${DOTFILES_LOG_FORMAT:=plain}"

_log_ts() { date -u +%FT%TZ; }
_log_level_rank() {
	case "$1" in
	ERROR) echo 0 ;; WARN) echo 1 ;; INFO) echo 2 ;; DEBUG) echo 3 ;; TRACE) echo 4 ;;
	*) echo 2 ;;
	esac
}

__LOG_THRESHOLD=$(_log_level_rank "$DOTFILES_LOG_LEVEL")
log_at() {
	local lvl="$1"
	shift || true
	local rank=$(_log_level_rank "$lvl")
	[ "$rank" -le "$__LOG_THRESHOLD" ] || return 0
	if [[ $DOTFILES_LOG_FORMAT == json ]]; then
		local msg component phase
		component="${LOG_COMPONENT:-}"
		phase="${LOG_PHASE:-}"
		msg="$*"
		if command -v jq >/dev/null 2>&1; then
			printf '{"ts":"%s","level":"%s","msg":%s' "$(_log_ts)" "$lvl" "$(printf '%s' "$msg" | jq -R '.')" >&2
			[[ -n $component ]] && printf ',"component":%s' "$(printf '%s' "$component" | jq -R '.')" >&2
			[[ -n $phase ]] && printf ',"phase":%s' "$(printf '%s' "$phase" | jq -R '.')" >&2
			printf '}\n' >&2
		else
			# Fallback escaping without jq: escape backslashes then quotes
			local esc=${msg//\\/\\\\}
			esc=${esc//"/\\"/}
			printf '{"ts":"%s","level":"%s","msg":"%s"}\n' "$(_log_ts)" "$lvl" "$esc" >&2
		fi
	else
		printf '[%s] %s\n' "$lvl" "$*" >&2
	fi
}
log_error() { log_at ERROR "$*"; }
log_warn() { log_at WARN "$*"; }
log_info() { log_at INFO "$*"; }
log_debug() { log_at DEBUG "$*"; }
log_trace() { log_at TRACE "$*"; }
