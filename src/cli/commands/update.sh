#!/usr/bin/env bash
# usage: dot update [--json] [--pull]
# summary: Show repo status (--json for structured output, --pull to update)
# group: core
set -euo pipefail
# All constants and paths are now provided by the dot script via environment variables
source "$CORE_DIR/init/bootstrap.sh"
core_require log update

JSON=0 PULL=0
for a in "$@"; do
	case $a in
	--json) JSON=1 ;;
	--pull) PULL=1 ;;
	-h | --help)
		grep '^# usage:' "$0" | sed 's/^# //'
		exit 0
		;;
	*) log_warn "Unknown flag $a" ;;
	esac
done

if [[ ! -d "$PROJECT_ROOT/.git" ]]; then
	log_warn "Not a git repository"
	exit 0
fi

branch=$(update_repo_branch)
current=$(update_current_ref)
remote=$(update_remote_ref)
state=$(update_state)

if [[ $PULL == 1 && $state == out-of-date ]]; then
	log_info "Pulling updates (branch $branch)"
	if update_pull; then
		remote=$(update_remote_ref)
		current=$(update_current_ref)
		state=$(update_state)
	else
		log_error "Pull failed"
		exit 2
	fi
fi

if [[ $JSON == 1 ]]; then
	printf '{"branch":"%s","current":"%s","remote":"%s","state":"%s"}' "$branch" "$current" "$remote" "$state"
	echo
	exit 0
fi

log_info "Branch: $branch"
log_info "Local:  $current"
log_info "Remote: $remote"
if [[ $state == up-to-date ]]; then
	log_info "Status: up-to-date"
else
	log_warn "Status: out-of-date"
fi

[[ $state == up-to-date ]] || exit 1
