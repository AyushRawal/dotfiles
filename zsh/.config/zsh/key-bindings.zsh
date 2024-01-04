# search history forward based on typing
autoload -U up-line-or-beginning-search
zle -N up-line-or-beginning-search

# search history backward based on typing
autoload -U down-line-or-beginning-search
zle -N down-line-or-beginning-search

# edit current command in editor
autoload -U edit-command-line
zle -N edit-command-line

bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

bindkey '^[[3;5~' kill-word                          # <C-Del>
bindkey '^[[3~' delete-char                          # <Del>
bindkey '^H' backward-kill-word                      # <C-BS> / <C-H>
bindkey '^W' vi-backward-kill-word
bindkey '^U' backward-kill-line
bindkey '^F' forward-char
bindkey '^B' backward-char

bindkey '^[[1;5C' forward-word                       # <C-Right>
bindkey '^[[1;5D' backward-word                      # <C-Left>

bindkey '^[[A' up-line-or-beginning-search           # <Up>
bindkey '^[[B' down-line-or-beginning-search         # <Down>
bindkey '^K' up-line-or-beginning-search
bindkey '^J' down-line-or-beginning-search
bindkey -M vicmd 'k' up-line-or-beginning-search
bindkey -M vicmd 'j' down-line-or-beginning-search
bindkey '^P' up-history
bindkey '^N' down-history

bindkey '^[[Z' reverse-menu-complete                 # <S-Tab>

bindkey -M vicmd 'Y' vi-yank-eol

bindkey -M viins '\C-x\C-e' edit-command-line        # <C-X><C-E>
bindkey -M vicmd '^V' edit-command-line
