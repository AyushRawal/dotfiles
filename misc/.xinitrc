#!/bin/sh
xrdb -merge ~/.Xresources

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

setxkbmap -option caps:swapescape &
lxsession &
dunst &
picom &
playerctld &
~/.local/bin/scripts/setwall &
xset s 300 30 &
~/.local/bin/scripts/locker.sh &
sxhkd &
~/.config/polybar/launch &
eww daemon &
exec qtile start
