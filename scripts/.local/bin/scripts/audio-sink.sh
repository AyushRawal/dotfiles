if [ "$#" -eq 0 ]; then
    pactl list sinks | grep Description | cut -d: -f2 | sed -e 's/^\s//g'
else
    desc="$*"
    device=$(pactl list sinks | grep -C2 -F "Description: $desc" | grep "Name" | cut -d: -f2 | sed -e 's/^\s//g')
    if pactl set-default-sink "$device"; then
        notify-send "Switched audio output to $desc"
    else
        notify-send "[FAILURE] Couldn't switch audio output"
    fi
fi
