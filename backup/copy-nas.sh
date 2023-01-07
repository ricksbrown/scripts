#!/bin/bash

# Run from root crontab
# 0 0 * * 0 /usr/bin/flock -n /tmp/copy-nas.lockfile /home/htpc/projects/scripts/backup/copy-nas.sh
#
# Also I don't think flock likes sharing users, so for testing don't use flock OR use flock only with the user
# you will using to run from cron.
#
# Read logger from /var/log/syslog, e.g. `tail /var/log/syslog`

declare -a dirs=("/mnt/Music" "/mnt/Pictures" "/mnt/Videos" "/mnt/nas") 

for DIR in "${dirs[@]}"
do
	localTarget="/home/htpc/nas/"
        if [ -d "${DIR}" ]; then
                logger "Copying $DIR to $localTarget"
                rsync -rv "$DIR" "$localTarget"
        else
                logger "Could not find ${DIR}"
        fi
done

