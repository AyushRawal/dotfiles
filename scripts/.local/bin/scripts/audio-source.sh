if [ "$#" -eq 0 ]; then
    pactl list sources | grep Description | cut -d: -f2 | sed -e 's/^\s//g'
else
    desc="$*"
    device=$(pactl list sources | grep -C2 -F "Description: $desc" | grep "Name" | cut -d: -f2 | sed -e 's/^\s//g')
    if pactl set-default-source "$device"; then
        notify-send "Switched audio input to $desc"
    else
        notify-send "[FAILURE] Couldn't switch audio input"
    fi
fi
