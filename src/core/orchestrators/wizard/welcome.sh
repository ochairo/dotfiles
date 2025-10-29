#!/usr/bin/env bash
# wizard/welcome.sh - Welcome screen

presets_show_welcome() {
    clear
    local title total_width
    total_width=$(tput cols 2>/dev/null || echo 120); (( total_width < 40 )) && total_width=40
    title="🔧 Dotfiles Installation Wizard"
    UI_FIXED_HEADER_LINES=("" "$title" "")
    UI_FIXED_HEADER_COUNT=3
    UI_FIXED_HEADER_SET=1
    ui_fixed_header_rerender
    echo "" >&2
    msg_info "This wizard will help you install and configure your dotfiles."
    msg_info "You can choose to install all components or select specific ones."
    echo ""
}
