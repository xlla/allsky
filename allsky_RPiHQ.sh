#!/bin/bash

CAMERA=RPiHQ

echo Stopping running allsky service when running, otherwise a warning is shown which can be ignored
/home/pi/allsky/stopallsky.sh

echo Starting AllSky for Raspberry Pi HQ camera...

ps -ef | grep allsky_RPiHQ.sh | grep -v $$ | xargs "sudo kill -9" 2>/dev/null

source /home/pi/allsky/config.sh
source /home/pi/allsky/scripts/filename.sh

echo "Starting allsky camera..."
cd /home/pi/allsky

# Building the arguments to pass to the capture binary
ARGUMENTS=""
KEYS=( $(jq -r 'keys[]' $CAMERA_SETTINGS) )
for KEY in ${KEYS[@]}
do
	ARGUMENTS="$ARGUMENTS -$KEY `jq -r '.'$KEY $CAMERA_SETTINGS` "
done

# When using a desktop environment (Remote Desktop, VNC, HDMI output, etc), a preview of the capture can be displayed in a separate window
# The preview mode does not work if allsky.sh is started as a service or if the debian distribution has no desktop environment.
if [[ $1 == "preview" ]] ; then
	ARGUMENTS="$ARGUMENTS -preview 1"
fi
ARGUMENTS="$ARGUMENTS -daytime $DAYTIME"

echo "$ARGUMENTS">>log.txt

./capture_RPiHQ $ARGUMENTS
