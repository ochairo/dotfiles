#!/usr/bin/env bash
# msg/width.sh - Terminal width detection

_msg_get_width() {
    local width stty_output
    if command -v stty >/dev/null 2>&1; then
        stty_output="$(stty size 2>/dev/null)" || stty_output=""
        if [[ -n $stty_output ]]; then
            width="${stty_output##* }"
            [[ $width =~ ^[0-9]+$ && $width -gt 0 ]] && { echo "$width"; return 0; }
        fi
    fi
    if width="$(tput cols 2>/dev/null)" && [[ $width =~ ^[0-9]+$ && $width -gt 0 ]]; then echo "$width"; return 0; fi
    if [[ -c /dev/tty ]]; then
        width="$(tput cols </dev/tty 2>/dev/null)" || width=""
        [[ $width =~ ^[0-9]+$ && $width -gt 0 ]] && { echo "$width"; return 0; }
    fi
    if [[ -n ${COLUMNS:-} && $COLUMNS =~ ^[0-9]+$ && $COLUMNS -gt 0 ]]; then echo "$COLUMNS"; return 0; fi
    echo 120
}
