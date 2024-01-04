bindkey -v

# Change cursor shape for different vi modes.
function zle-keymap-select () {
  case $KEYMAP in
    vicmd) echo -ne '\e[2 q';; # block
    viins) echo -ne '\e[6 q';; # beam
    main)  echo -ne '\e[6 q';; # beam
    *)     echo -ne '\e[6 q';; # beam
  esac
}
zle -N zle-keymap-select

zle-line-init() {
  # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
  zle -K viins
  echo -ne "\e[6 q"
}
zle -N zle-line-init

# use beam cursor for each prompt
_fix_cursor() {
  echo -ne '\e[6 q'
}
precmd_functions+=(_fix_cursor)

# vi yank / cut to clipboard
function wrap_clipboard_widgets() {
  local verb="$1"
  shift

  local widget
  local wrapped_name
  for widget in "$@"; do
    wrapped_name="_zsh-vi-${verb}-${widget}"
    if [ "${verb}" = copy ]; then
      eval "
      function ${wrapped_name}() {
      zle .${widget}
      xclip -in -selection clipboard <<<\$CUTBUFFER
    }
    "
  else
    eval "
    function ${wrapped_name}() {
    CUTBUFFER=\$(xclip -out -selection clipboard)
    zle .${widget}
  }
  "
    fi
    zle -N "${widget}" "${wrapped_name}"
  done
}

wrap_clipboard_widgets copy vi-yank vi-yank-eol vi-backward-kill-word vi-change-whole-line vi-delete vi-delete-char
wrap_clipboard_widgets paste vi-put-{before,after}
unfunction wrap_clipboard_widgets
