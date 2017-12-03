#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

if [ $# -eq 0 ]
  then
    echo -e "${RED}You forgot to pass the architecture argument (armv6, armv7, x86 or x64)${NC}"
	exit 3
fi
arch=$1

echo -en '\n'
echo -e "${RED}**********************************************"
echo    "*** Welcome to the Allsky Camera installer ***"
echo -e "**********************************************${NC}"
echo -en '\n'
echo -en "${GREEN}* Sunwait installation"
cp sunwait /usr/local/bin
echo -en '\n'
echo -en "${GREEN}* Dependencies installation${NC}\n"
apt-get update && apt-get install libopencv-dev libusb-dev libav-tools gawk lftp entr xterm jq cpulimit imagemagick -y
echo -en '\n'
echo -en "${GREEN}* Using the camera without root access${NC}\n"
install asi.rules /lib/udev/rules.d
echo -en '\n'
echo -en "${GREEN}* Copying shared libraries to user library${NC}\n"
cp lib/$arch/libASICamera2* /usr/local/lib
ldconfig
echo -en '\n'
echo -en "${GREEN}* Compile allsky software${NC}\n"
make capture arch=$arch
echo -en '\n'
echo -en "${GREEN}* Copy camera settings files${NC}\n"
cp settings.json.repo settings.json
cp config.sh.repo config.sh
chown -R $SUDO_USER:$SUDO_USER ../allsky
if [ "$arch" = "armv6" ] || [ "$arch" = "armv7" ]; then
	echo -en '\n'
	echo -en "${GREEN}* Autostart script${NC}"
	echo -en '\n'
	read -p "Do you want to autostart allsky at boot time? [Y/n] " ans_yn
	case "$ans_yn" in
	  [Nn]|[Nn][Oo]);;
	  *) echo "@xterm -hold -e /home/pi/allsky/allsky.sh" >> /home/pi/.config/lxsession/LXDE-pi/autostart;;
	esac
fi
echo -en '\n'
echo -en '\n'
echo "The Allsky Camera is now installed."
if [ "$arch" = "armv6" ] || [ "$arch" = "armv7" ]; then
	echo "You can now reboot the Raspberry Pi."
	echo -en '\n'
	read -p "Do you want to reboot now? [y/N] " ans_yn
	case "$ans_yn" in
	  [Yy]|[Yy][Ee][Ss]) reboot now;;
	  *) exit 3;;
	esac
fi
