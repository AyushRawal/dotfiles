#!/bin/sh

xidlehook \
  --not-when-audio \
  --socket ~/.cache/xidlehook.sock \
  --timer 120 "$HOME/.local/bin/scripts/dim-screen.sh" 'killall dim-screen.sh' \
  --timer 200 'killall dim-screen.sh; betterlockscreen -l dimblur' '' \
  --timer 600 'killall dim-screen.sh; systemctl suspend-then-hibernate' ''
