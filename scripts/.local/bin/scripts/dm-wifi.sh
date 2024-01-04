#!/bin/sh

status=$(wifi | cut -d '=' -f2 | tr -d ' ')
if [ "$status" = 'on' ]; then
    options=$(nmcli device wifi list | sed -n '1!p' && echo 'Disconnect' && echo 'Disable wifi')
    choice=$(echo "$options" | dmenu -p "Select wifi" -l 10)
    if [[ -n "$choice" ]]; then
        if [ "$choice" = "Disconnect" ]; then
            nmcli device disconnect wlp0s20f3
        elif [ "$choice" = 'Disable wifi' ]; then
            wifi off
        else
            bssid=$(echo "$choice" | cut -b 9- | cut -d ' ' -f1)
            nmcli device wifi connect "$bssid"
        fi
    fi
else
    comm=$(echo "Enable wifi" | dmenu)
    if [ "$comm" = "Enable wifi" ]; then
        wifi on
    fi
fi

