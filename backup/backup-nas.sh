#!/bin/bash
# Run from root crontab
# 0 22 * * * /usr/bin/flock -n /tmp/backup-nas.lockfile /home/htpc/projects/scripts/backup/backup-nas.sh

# Setup:
# sudo apt install s3cmd
# s3cmd --configure
# Configure requires you to sign in to the Amazon console and generate Access and Secret Keys
# https://s3tools.org/s3cmd-howto
#
# This creates a .s3cmd config file in the user home directory. If you configure it as one user and then
# rubn it as another, e.g. root, you need to symlink it, for example, created as user `htpc` but run as root:
# ln -s /home/htpc/.s3cfg /root/
#
# Also I don't think flock likes sharing users, so for testing don't use flock OR use flock only with the user
# you will using to run from cron.

# "/mnt/rdocs/" "/mnt/jdocs/" "/mnt/vdocs/"
# /home/htpc/.config/homeassistant/

declare -a dirs=("/home/htpc/Pictures" "/home/htpc/Music/" "/home/htpc/.config/homeassistant/")
#declare -a dirs=("/home/htpc/.config/homeassistant/")

for DIR in "${dirs[@]}"
do
	dirname=$(basename -- "${DIR}")
	s3target="s3://petalbear/${dirname}/"
	if [ -d "${DIR}" ]; then
		echo "Backing up ${DIR} to ${s3target}"
		s3cmd sync "${DIR}" --delete-removed --preserve "${s3target}"
	else
		echo "Could not find ${DIR}"
	fi
done
