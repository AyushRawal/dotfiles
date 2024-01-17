export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

export KEYTIMEOUT=1

export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"
export FZF_DEFAULT_COMMAND='fd -H -E .git'
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
export FZF_ALT_C_COMMAND='fd -H -t d -E .git'
export FZF_DEFAULT_OPTS='--reverse --height 40% -m'
# export FNM_DIR=$HOME/.config/fnm
# export PRETTIERD_DEFAULT_CONFIG=$HOME/.prettierrc
export DELTA_PAGER="less -R"
export LESS='-R'
export EDITOR='nvim'

export GOPATH="$HOME/.local/go"

# export PATH=$HOME/.fnm:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.local/bin/scripts:$PATH
export PATH=$GOPATH/bin:$PATH
export PATH=$HOME/.local/share/nvim/mason/bin:$PATH
export PATH=$HOME/.config/emacs/bin:$PATH

export TEMPLATE_PATH=$HOME/code/cp/template.cpp

# fnm
# eval "$(fnm env)"

# vim: set ft=sh:
