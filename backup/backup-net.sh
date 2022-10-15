#!/bin/bash
# Run from crontab
BACKUP_DIR='/home/htpc/.config/fritz'
mkdir -p $BACKUP_DIR
logger "Logging fritz hostnames to $BACKUP_DIR/hostnames"
/home/htpc/projects/scripts/fritz/devices.py > $BACKUP_DIR/hostnames

