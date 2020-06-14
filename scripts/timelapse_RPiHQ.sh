#!/bin/bash

source /home/pi/allsky/config.sh
source /home/pi/allsky/scripts/filename.sh

cd /home/pi/allsky/

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

if [ $# -lt 1 ]
  then
	echo -en "${RED}You need to pass a day argument\n"
		echo -en "    ex: timelapse_RPiHQ.sh 20180119${NC}\n"
		exit 3
fi

echo -en "* ${GREEN}Copying image files to images/$1/small${NC}\n"
mkdir images/$1/small
cp images/$1/*.$EXTENSION images/$1/small

echo -en "* ${GREEN}Resize images...${NC}\n"
scripts/batch-image-resize.sh $1/small

echo -en "* ${GREEN}Creating symlinks to generate timelapse${NC}\n"
mkdir /home/pi/allsky/images/$1/small/sequence/
# find images, make symlinks sequentially and start avconv to build mp4; upload mp4 and move directory
find "/home/pi/allsky/images/$1/small" -name "*.$EXTENSION" -size 0 -delete
ls -a /home/pi/allsky/images/$1/small/*.$EXTENSION |
gawk 'BEGIN{ a=1 }{ printf "ln -sv %s /home/pi/allsky/images/'$1'/small/sequence/%04d.'$EXTENSION'\n", $0, a++ }' |
bash
ffmpeg -y -f image2 -r $FPS -i images/$1/small/sequence/%04d.$EXTENSION -vcodec libx264 -b:v 2000k -pix_fmt yuv420p images/$1/allsky-$1.mp4

echo -en "* ${GREEN}Upload video${NC}\n"
if [ "$UPLOAD_VIDEO" = true ] ; then
	lftp "$PROTOCOL"://"$USER":"$PASSWORD"@"$HOST":"$MP4DIR" -e "set net:max-retries 1; put images/$1/allsky-$1.mp4; bye"
fi

echo -en "* ${GREEN}Deleting sequence${NC}\n"
rm -rf /home/pi/allsky/images/$1/small

echo -en "* ${GREEN}Timelapse was created${NC}\n"
