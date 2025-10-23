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
MSG_THRESHOLD=$(case "$MSG_LEVEL" in
    ERROR) echo $MSG_LEVEL_ERROR ;;
    WARN)  echo $MSG_LEVEL_WARN ;;
    INFO)  echo $MSG_LEVEL_INFO ;;
    DEBUG) echo $MSG_LEVEL_DEBUG ;;
    *) echo $MSG_LEVEL_INFO ;;
esac)

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

# Basic message functions
msg_error() {
    _msg_should_print "$MSG_LEVEL_ERROR" || return 0
    printf "${C_RED}✗ [ERROR]${C_RESET} %s\n" "$*" >&2
}

msg_warn() {
    _msg_should_print "$MSG_LEVEL_WARN" || return 0
    printf "${C_YELLOW}⚠ [WARN]${C_RESET} %s\n" "$*"
}

msg_info() {
    _msg_should_print "$MSG_LEVEL_INFO" || return 0
    printf "${C_BLUE}ℹ [INFO]${C_RESET} %s\n" "$*"
}

msg_success() {
    _msg_should_print "$MSG_LEVEL_INFO" || return 0
    printf "${C_GREEN}✓ [SUCCESS]${C_RESET} %s\n" "$*"
}

msg_debug() {
    _msg_should_print "$MSG_LEVEL_DEBUG" || return 0
    printf "${C_DIM}⚬ [DEBUG]${C_RESET} %s\n" "$*"
}

# Header with terminal-wide colored lines
msg_header() {
    _msg_should_print "$MSG_LEVEL_INFO" || return 0

    local text="$*"
    local width
    width=$(_msg_get_width)

    # Print top line
    printf "\n${C_CYAN}"
    printf "%*s\n" "$width" "" | tr ' ' '─'
    printf "${C_RESET}"

    # Print empty line above text
    printf "${C_CYAN}║${C_RESET}"
    printf "%*s" "$((width - 2))" ""
    printf "${C_CYAN}║${C_RESET}\n"

    # Print centered text
    local text_len=${#text}

    # If text is too long, truncate it
    if [[ $text_len -gt $((width - 6)) ]]; then
        text="${text:0:$((width - 9))}..."
        text_len=${#text}
    fi

    local padding=$(( (width - text_len - 4) / 2 ))  # -4 for "║ " and " ║"
    local right_padding=$(( width - text_len - 4 - padding ))  # Handle odd widths

    printf "${C_CYAN}║${C_RESET} "
    printf "%*s" "$padding" ""
    printf "${C_BOLD}${C_CYAN}%s${C_RESET}" "$text"
    printf "%*s" "$right_padding" ""
    printf " ${C_CYAN}║${C_RESET}\n"

    # Print empty line below text
    printf "${C_CYAN}║${C_RESET}"
    printf "%*s" "$((width - 2))" ""
    printf "${C_CYAN}║${C_RESET}\n"

    # Print bottom line
    printf "${C_CYAN}"
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
