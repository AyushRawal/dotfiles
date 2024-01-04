#!/usr/bin/env bash
set -xe

lxsession &
swaybg --mode fill --image ~/Pictures/Wallpapers/Universal/home-sweet-home.jpg &
swayosd-server &
swaync &
waybar &
eww daemon &
emacs --daemon &

# timeout 300 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' \
swayidle \
  timeout 300 '$HOME/.local/bin/scripts/dim-screen.sh' resume 'killall dim-screen.sh' \
  timeout 600 'killall dim-screen.sh; pgrep -x swaylock || swaylock' \
  timeout 900 'killall dim-screen.sh; systemctl suspend-then-hibernate' \
  lock 'killall dim-screen.sh; swaylock' \
  before-sleep 'killall dim-screen.sh; pgrep -x swaylock || swaylock' &
