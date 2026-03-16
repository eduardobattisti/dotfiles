# Key bindings

# Open command line in $EDITOR with Ctrl-X Ctrl-E
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# Expand history expressions (!! / !$) on space
bindkey ' ' magic-space
