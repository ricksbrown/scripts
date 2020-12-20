#!/bin/bash

# Samsung soundbar goes to sleep after about 18 mins of no sound.
# This is annoying when pausing a show.
# This script will keep it alive if run from cron something like:
# */15 * * * * /home/htpc/apps/nag.nag.sh

export XDG_RUNTIME_DIR="/run/user/1000"

if ! pactl list sinks | grep -qi "State: running"; then
	echo 'Keeping soundbar awake'
	# echo $'\a'
	currenttime=$(date +%H:%M)
   	if [[ "$currenttime" > "20:29" ]] && [[ "$currenttime" < "23:30" ]]; then
     		msg='Hello, Children go to bed'
   	elif [[ "$currenttime" > "18:55" ]] && [[ "$currenttime" < "20:01" ]]; then
		msg='Hello, Children do your chores'
	else
     		msg='Hello Jesse do your homework!'
   	fi
	espeak -v en "$msg" --stdout | aplay
fi
