#!/usr/bin/env bash
# term.sh - Terminal capability detection
# Reusable across any shell script project (macOS and Linux compatible)

# Prevent double loading
[[ -n "${SYSTEM_TERM_LOADED:-}" ]] && return 0
readonly SYSTEM_TERM_LOADED=1

# Terminal capability flags
TERM_TRUECOLOR=0
TERM_256COLOR=0
TERM_EMOJI=0
TERM_INTERACTIVE=0

export TERM_TRUECOLOR TERM_256COLOR TERM_EMOJI TERM_INTERACTIVE

# Detect terminal capabilities
# Sets global variables: TERM_TRUECOLOR, TERM_256COLOR, TERM_EMOJI, TERM_INTERACTIVE
# Example: term_detect
term_detect() {
    # Detect truecolor support
    if [[ ${COLORTERM:-} == *truecolor* ]] || [[ ${COLORTERM:-} == *24bit* ]]; then
        TERM_TRUECOLOR=1
        TERM_256COLOR=1
    elif grep -qi 'truecolor\|24bit' <<<"${TERM:-}"; then
        TERM_TRUECOLOR=1
        TERM_256COLOR=1
    elif command -v tput >/dev/null 2>&1; then
        local colors
        colors=$(tput colors 2>/dev/null || echo "0")
        if [[ $colors -ge 256 ]]; then
            TERM_256COLOR=1
        fi
    fi

    # Detect emoji support (mainly macOS, modern Linux terminals)
    case "${OSTYPE:-}" in
        darwin*) TERM_EMOJI=1 ;;
        linux*)
            # Most modern Linux terminals support emoji
            if [[ -n "${DISPLAY:-}" ]] || [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
                TERM_EMOJI=1
            fi
            ;;
    esac

    # Check for user override
    [[ ${DOTFILES_NO_EMOJI:-0} == 1 ]] && TERM_EMOJI=0
    [[ ${NO_EMOJI:-0} == 1 ]] && TERM_EMOJI=0

    # Detect interactive terminal
    if [[ -t 0 ]] && [[ -t 1 ]]; then
        TERM_INTERACTIVE=1
    fi

    export TERM_TRUECOLOR TERM_256COLOR TERM_EMOJI TERM_INTERACTIVE
}

# Check if terminal supports true color (24-bit)
# Returns: 0 if supported, 1 otherwise
# Example: if term_supports_truecolor; then echo "24-bit color!"; fi
term_supports_truecolor() {
    [[ $TERM_TRUECOLOR -eq 1 ]]
}

# Check if terminal supports 256 colors
# Returns: 0 if supported, 1 otherwise
# Example: if term_supports_256color; then echo "256 colors!"; fi
term_supports_256color() {
    [[ $TERM_256COLOR -eq 1 ]]
}

# Check if terminal supports emoji
# Returns: 0 if supported, 1 otherwise
# Example: if term_supports_emoji; then echo "🎉"; fi
term_supports_emoji() {
    [[ $TERM_EMOJI -eq 1 ]]
}

# Check if running in interactive terminal
# Returns: 0 if interactive, 1 otherwise
# Example: if term_is_interactive; then read -p "Continue? "; fi
term_is_interactive() {
    [[ $TERM_INTERACTIVE -eq 1 ]]
}

# Get terminal width in columns
# Returns: number of columns
# Example: width=$(term_width)
term_width() {
    if command -v tput >/dev/null 2>&1; then
        tput cols 2>/dev/null || echo "80"
    else
        echo "80"
    fi
}

# Get terminal height in rows
# Returns: number of rows
# Example: height=$(term_height)
term_height() {
    if command -v tput >/dev/null 2>&1; then
        tput lines 2>/dev/null || echo "24"
    else
        echo "24"
    fi
}

# Clear terminal screen
# Example: term_clear
term_clear() {
    if command -v tput >/dev/null 2>&1; then
        tput clear 2>/dev/null || clear
    else
        clear 2>/dev/null || printf '\033[2J\033[H'
    fi
}

# Move cursor to position
# Args: row, column
# Example: term_cursor_move 10 20
term_cursor_move() {
    local row="${1:-1}"
    local col="${2:-1}"
    if command -v tput >/dev/null 2>&1; then
        tput cup "$row" "$col" 2>/dev/null
    else
        printf '\033[%d;%dH' "$row" "$col"
    fi
}

# Hide cursor
# Example: term_cursor_hide
term_cursor_hide() {
    if command -v tput >/dev/null 2>&1; then
        tput civis 2>/dev/null
    else
        printf '\033[?25l'
    fi
}

# Show cursor
# Example: term_cursor_show
term_cursor_show() {
    if command -v tput >/dev/null 2>&1; then
        tput cnorm 2>/dev/null
    else
        printf '\033[?25h'
    fi
}

# Get terminal name
# Returns: terminal emulator name if detectable
# Example: term_name
term_name() {
    if [[ -n "${TERM_PROGRAM:-}" ]]; then
        echo "${TERM_PROGRAM}"
    elif [[ -n "${TERMINAL_EMULATOR:-}" ]]; then
        echo "${TERMINAL_EMULATOR}"
    elif [[ -n "${TERM:-}" ]]; then
        echo "${TERM}"
    else
        echo "unknown"
    fi
}

# Check if running in specific terminal
# Args: terminal_name (e.g., "iTerm", "WezTerm", "Alacritty")
# Returns: 0 if match, 1 otherwise
# Example: if term_is "iTerm.app"; then echo "Using iTerm2"; fi
term_is() {
    local name="${1}"
    [[ "$(term_name)" == *"$name"* ]]
}

# Auto-detect capabilities on load
term_detect
