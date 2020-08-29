#!/usr/bin/env bash
# Purpose: batch image resizer
# Source: https://guides.wp-bullet.com
# Author: Mike

# absolute path to image folder
FOLDER=~/allsky/images/${1}/small
#echo "Resizing images in folder ${FOLDER}..."

# max width
WIDTH=1920

# max height
HEIGHT=1078

#resize png or jpg to either height or width, keeps proportions using imagemagick
#find ${FOLDER} -iname '*.jpg' -o -iname '*.png' -exec convert \{} -verbose -resize $WIDTHx$HEIGHT\> \{} \;

#resize png to either height or width, keeps proportions using imagemagick
#find ${FOLDER} -iname '*.png' -exec convert \{} -verbose -resize $WIDTHx$HEIGHT\> \{} \;

#resize jpg only to either height or width, keeps proportions using imagemagick
#find ${FOLDER} -maxdepth 1 -iname 'image-*.jpg' -exec nice convert \{} -verbose -resize ${WIDTH}x${HEIGHT}\> \{} \;
find ${FOLDER} -maxdepth 1 -iname 'image-*.jpg' -exec nice convert \{} -verbose -adaptive-resize 1920x1078\> \{} \;

# alternative
#mogrify -path ${FOLDER} -resize ${WIDTH}x${HEIGHT}% *.png -verbose
