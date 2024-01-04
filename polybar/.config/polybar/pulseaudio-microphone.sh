#!/bin/sh

status() {
  MUTED=$(pactl get-source-mute @DEFAULT_SOURCE@ | cut -d " " -f2)

  if [ "$MUTED" = "yes" ]; then
    echo "%{F#504945}[Mic: M]"
  else
      echo "[%{F#D8A657}Mic:%{F#DDC7A1} $(pactl get-source-volume @DEFAULT_SOURCE@ | grep '[0-9]*%' -o | head -n 1)]"
  fi
}

listen() {
    status

    LANG=EN; pactl subscribe | while read -r event; do
        if echo "$event" | grep -q "source" || echo "$event" | grep -q "server"; then
            status
        fi
    done
}

toggle() {
  MUTED=$(pactl get-source-mute @DEFAULT_SOURCE@ | cut -d " " -f2)

  if [ "$MUTED" = "yes" ]; then
      pactl set-source-mute @DEFAULT_SOURCE@ 0
  else
      pactl set-source-mute @DEFAULT_SOURCE@ 1
  fi
}

increase() {
  pactl set-source-volume @DEFAULT_SOURCE@ +5%
}

decrease() {
  pactl set-source-volume @DEFAULT_SOURCE@ -5%
}

case "$1" in
    --toggle)
        toggle
        ;;
    --increase)
        increase
        ;;
    --decrease)
        decrease
        ;;
    *)
        listen
        ;;
esac
