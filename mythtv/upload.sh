#!/bin/bash
#
# First arg to this script should be the file to upload
# 1 = FILE
# 2 = ENDTIME
# 3 = DIR
# 4 = TITLE
#
# Read logger logs with sudo tail -f /var/log/syslog

# Check if args provided
if [[ $# -eq 0 ]] ; then
	logger "No args provided to mythtv gdrive upload script"
	exit 1
fi
logger "Running gdrive upload script with args $@"
mythtv=1CSg7StgpVGoOkgaC2VR1wFwl2hWbGH0K

recording_file="$3/$1"
if test -f "$recording_file"; then
	temp_dir=$(mktemp -d)
	if [[ "$4" =~ ^Outsider.* ]]; then
    		title="Outsiders"
	else
		title="$4"
	fi
	# short_title=${title:0:9}
	# The below two commented lines would just do a straight copy but fix the name
	# temp_file="$temp_dir/${title}_$1"
	# cp "$recording_file" "$temp_file"
	
	temp_file="$temp_dir/${title}_$2.mp4"
	logger "transcoding so gdrive upload is smaller: ${temp_file}"
	#ffmpeg -i "$recording_file" -c:v libx264 "$temp_file"
	ffmpeg -i "$recording_file" -vcodec libx264 -crf 24 "$temp_file"
	logger "asking gdrive to upload ${temp_file}"
	/home/htpc/apps/gdrive/gdrive files upload --parent $mythtv "$temp_file"  
fi

