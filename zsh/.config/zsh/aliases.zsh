# Colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# confirm before overwriting something
alias cp="cp -i"
alias mv='mv -i'

# annoying, but saves ass
alias rm='rm -i'

# easier to read disk
alias df='df -h'
alias free='free -h'
alias du='du -h'

# directory stack
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index

# ls
if _is_cmd eza; then
  alias ls='eza --group-directories-first --icons'
  alias ll='eza --group-directories-first --icons -la'
  alias la='eza --group-directories-first --icons -a'
  alias lr='eza --group-directories-first --icons -R'
  lt() {
    depth=2
    [ $# -eq 0 ] || depth=$1
    eza --group-directories-first --tree --level=$depth
  }
# if _is_cmd lsd; then
#   alias ls='lsd --group-directories-first'
#   alias ll='lsd --group-directories-first -lA --date "+%_d %b %y %_H:%M"'
#   alias la='lsd --group-directories-first -A'
#   alias lr='lsd --group-directories-first -R'
#   lt() {
#     depth=2
#     [ $# -eq 0 ] || depth=$1
#     lsd --group-directories-first --tree --depth=$depth
#   }
else
  alias ls="ls --color=auto --group-directories-first"
  alias ll='ls --group-directories-first -lAh'
  alias la='ls --group-directories-first -A'
  alias lr='ls --group-directories-first -R'
  lt() {
    depth=2
    [ $# -eq 0 ] || depth=$1
    tree --dirsfirst -L $depth
  }
fi

alias vi="nvim"
alias hx="helix"

if _is_cmd bat; then
  alias cat="bat"
fi

alias open="xdg-open"
alias drgn="dragon-drop"
alias esc="setxkbmap -option caps:swapescape"
alias cpfile="xclip-copyfile"
alias cutfile="xclip-cutfile"
alias pastefile="xclip-pastefile"

# fzf cd
alias fcd='cd $(eval $FZF_ALT_C_COMMAND | fzf +m)'

# git diff with syntax hl
alias batdiff="git diff --name-only --diff-filter=d | xargs bat --diff"

wttr() {
  if [ "$#" -eq 0 ]; then
    if [[ -f $HOME/.local/share/location ]]; then
      loc="$(<$HOME/.local/share/location)"
    fi
  else
    loc=$1
  fi
  curl -s wttr.in/$loc | less
}

alias tt="eztmux dir"
alias ts="eztmux switch"
alias tn="eztmux name"
alias nb="eztmux dir ~/Notes"

alias gs="git status"
