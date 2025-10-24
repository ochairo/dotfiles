#!/usr/bin/env bash
# msg.sh - Simple message printing utility
# Reusable across any shell script project

# Prevent double loading
[[ -n "${MSG_LOADED:-}" ]] && return 0
readonly MSG_LOADED=1

# Message levels
readonly MSG_LEVEL_ERROR=1
readonly MSG_LEVEL_WARN=2
readonly MSG_LEVEL_INFO=3
readonly MSG_LEVEL_DEBUG=4

# Current log level (can be overridden)
MSG_LEVEL=${MSG_LEVEL:-INFO}
case "$MSG_LEVEL" in
    ERROR) MSG_THRESHOLD=$MSG_LEVEL_ERROR ;;
    WARN)  MSG_THRESHOLD=$MSG_LEVEL_WARN ;;
    INFO)  MSG_THRESHOLD=$MSG_LEVEL_INFO ;;
    DEBUG) MSG_THRESHOLD=$MSG_LEVEL_DEBUG ;;
    *) MSG_THRESHOLD=$MSG_LEVEL_INFO ;;
esac

# Terminal width detection
_msg_get_width() {
    local width

    # Method 1: stty size (most reliable in subshells)
    if command -v stty >/dev/null 2>&1; then
        local stty_output
        stty_output="$(stty size 2>/dev/null)" || stty_output=""
        if [[ -n "$stty_output" ]]; then
            width="${stty_output##* }"  # Get the second number (columns)
            if [[ "$width" =~ ^[0-9]+$ ]] && [[ $width -gt 0 ]]; then
                echo "$width"
                return 0
            fi
        fi
    fi

    # Method 2: Direct tput call
    if width="$(tput cols 2>/dev/null)" && [[ "$width" =~ ^[0-9]+$ ]] && [[ $width -gt 0 ]]; then
        echo "$width"
        return 0
    fi

    # Method 3: tput with /dev/tty
    if [[ -c /dev/tty ]]; then
        width="$(tput cols </dev/tty 2>/dev/null)" || width=""
        if [[ "$width" =~ ^[0-9]+$ ]] && [[ $width -gt 0 ]]; then
            echo "$width"
            return 0
        fi
    fi

    # Method 4: COLUMNS environment variable
    if [[ -n "${COLUMNS:-}" ]] && [[ "$COLUMNS" =~ ^[0-9]+$ ]] && [[ $COLUMNS -gt 0 ]]; then
        echo "$COLUMNS"
        return 0
    fi

    # Fallback to reasonable default
    echo "120"
}

# Level checking
_msg_should_print() {
    local level_num="$1"
    [[ "$level_num" -le "$MSG_THRESHOLD" ]]
}

# ============================================================================
# Base Primitives (DRY - reusable building blocks)
# ============================================================================

# Flexible print to stderr (most general)
# Interprets backslash escapes in the format string
msg_print() {
    # shellcheck disable=SC2059
    printf "$@" >&2
}

# Blank line to stderr
msg_blank() {
    printf "\n" >&2
}

# Print with icon and color
msg_with_icon() {
    local icon="$1"
    local color="$2"
    shift 2
    printf "${color}${icon}${C_RESET} %s\n" "$*" >&2
}

# Prompt without newline
msg_prompt() {
    printf "${C_BLUE}❯${C_RESET} " >&2
}

# Dimmed text without prefix/icon (for UI elements and status displays)
msg_dim() {
    printf "${C_DIM}%s${C_RESET}\n" "$*" >&2
}

# ============================================================================
# Application Messages (use base primitives)
# ============================================================================

# Basic message functions
msg_error() {
    _msg_should_print "$MSG_LEVEL_ERROR" || return 0
    msg_with_icon "✗ [ERROR]" "$C_RED" "$@"
}

msg_warn() {
    _msg_should_print "$MSG_LEVEL_WARN" || return 0
    msg_with_icon "⚠ [WARN]" "$C_YELLOW" "$@"
}

msg_info() {
    _msg_should_print "$MSG_LEVEL_INFO" || return 0
    msg_with_icon "ℹ [INFO]" "$C_BLUE" "$@"
}

msg_success() {
    _msg_should_print "$MSG_LEVEL_INFO" || return 0
    msg_with_icon "✓ [SUCCESS]" "$C_GREEN" "$@"
}

msg_debug() {
    _msg_should_print "$MSG_LEVEL_DEBUG" || return 0
    msg_with_icon "⚬ [DEBUG]" "$C_DIM" "$@"
}

# Header with terminal-wide colored lines
msg_header() {
    _msg_should_print "$MSG_LEVEL_INFO" || return 0

    local text="$*"
    local width
    width=$(_msg_get_width)

    # Print top line
    printf "\n${C_PURPLE}"
    printf "%*s\n" "$width" "" | tr ' ' '─'
    printf "${C_RESET}\n"

    # Print centered text with padding
    local text_len=${#text}

    # If text is too long, truncate it
    if [[ $text_len -gt $((width - 4)) ]]; then
        text="${text:0:$((width - 7))}..."
        text_len=${#text}
    fi

    local padding=$(( (width - text_len) / 2 ))
    local right_padding=$(( width - text_len - padding ))

    printf "%*s" "$padding" ""
    printf "${C_BOLD}${C_PURPLE}%s${C_RESET}" "$text"
    printf "%*s\n" "$right_padding" ""

    # Print bottom line
    printf "${C_PURPLE}"
    printf "%*s\n" "$width" "" | tr ' ' '─'
    printf "${C_RESET}\n"
}

# Progress indicator
msg_progress() {
    _msg_should_print "$MSG_LEVEL_INFO" || return 0

    local current="$1"
    local total="$2"
    shift 2
    local text="$*"

    local percent=$(( current * 100 / total ))
    printf "${C_DIM}[%d/%d]${C_RESET} %s ${C_DIM}(%d%%)${C_RESET}\n" \
        "$current" "$total" "$text" "$percent"
}

# Set message level
msg_set_level() {
    case "${1^^}" in
        ERROR) MSG_LEVEL="ERROR"; MSG_THRESHOLD=$MSG_LEVEL_ERROR ;;
        WARN)  MSG_LEVEL="WARN";  MSG_THRESHOLD=$MSG_LEVEL_WARN ;;
        INFO)  MSG_LEVEL="INFO";  MSG_THRESHOLD=$MSG_LEVEL_INFO ;;
        DEBUG) MSG_LEVEL="DEBUG"; MSG_THRESHOLD=$MSG_LEVEL_DEBUG ;;
        *) return 1 ;;
    esac
}
