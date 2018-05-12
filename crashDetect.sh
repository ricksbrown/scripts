#!/bin/sh

# PROCESS="$1"
# PROCANDARGS=$*

# This script is intended to detect that minecraft server has crashed and restart it.
# It is a modified version of https://stackoverflow.com/a/16787862/3847000
# Start it from cron something like so: 
# @reboot /path/to/crashDetect.sh

# You can fetch this script like so:
# wget https://raw.githubusercontent.com/ricksbrown/scripts/master/crashDetect.sh
# Then of course you will need:
# chmod +x crashDetect.sh

PROCESS="java"
PROCANDARGS="./launchmcRB.sh"

while :
do
    sleep 300
    RESULT=`pgrep ${PROCESS}`

    if [ "${RESULT:-null}" = null ]; then
            echo "crash detected at: "`date -u` >> crashDetect.log
            echo "  > starting "$PROCANDARGS >> crashDetect.log
            $PROCANDARGS &
    else
            echo "running"
    fi
    # sleep 10
done

