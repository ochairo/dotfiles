#!/usr/bin/env bash
# errors/context.sh - Error context stack operations

# shellcheck disable=SC2034
declare -a ERROR_CONTEXT_STACK=()

error_context() { ERROR_CONTEXT_STACK+=("$*"); }
error_context_pop() { [[ ${#ERROR_CONTEXT_STACK[@]} -gt 0 ]] && unset 'ERROR_CONTEXT_STACK[-1]'; }
error_context_clear() { ERROR_CONTEXT_STACK=(); }
