# fzf integration placeholder
# fzf.zsh - fzf integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!{.git,node_modules}"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
