#!/usr/bin/env bash
# wizard/complete.sh - Completion screen

presets_show_completion() {
    # Minimal completion output (banner removed per user request)
    msg_success "Installation complete"
    msg_info "Next steps:"
    msg_print "  • Run 'dot health' to verify component status\n"
    msg_print "  • Run 'dot status' to see symlink status\n"
    msg_print "  • Restart your shell or run 'source ~/.zshrc' (or ~/.bashrc)\n"
    msg_blank
}
