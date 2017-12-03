#!/bin/bash

# Find current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Enter directory
cd $DIR

# Read configuration file
source config.sh

echo "Starting allsky camera..."

# Building the arguments to pass to the capture binary
ARGUMENTS=""
KEYS=( $(jq -r 'keys[]' $CAMERA_SETTINGS) )
for KEY in ${KEYS[@]}
do
	ARGUMENTS="$ARGUMENTS -$KEY `jq -r '.'$KEY $CAMERA_SETTINGS` "
done
echo "$ARGUMENTS">>log.txt

# When a new image is captured, we launch saveImage.sh
ls $FULL_FILENAME | entr ./saveImage.sh & \
# Uncomment the following line if you get a segmentation fault during timelapse on a Pi3
#cpulimit -e avconv -l 50 & \
./capture $ARGUMENTS
