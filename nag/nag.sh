#!/bin/bash
# Detects if sound is active before running the nag script.
# This prevents it talking over the top of a TV show etc.

export XDG_RUNTIME_DIR="/run/user/1000"

if ! pactl list sinks | grep -qi "State: running"; then
        echo 'Keeping soundbar awake'
        CWD="$(dirname "$(readlink -f "$0")")"
        cd $CWD
        /usr/bin/python3 "$CWD/nag.py" ${1:-student_one}
fi
