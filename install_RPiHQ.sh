#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
echo -en '\n'
echo -e "${RED}**********************************************"
echo    "*** Welcome to the Allsky Camera installer ***"
echo -e "**********************************************${NC}"
echo -en '\n'

echo -en "${GREEN}* Dependencies installation\n${NC}"
apt-get update && apt-get install libopencv-dev libusb-dev ffmpeg gawk lftp jq imagemagick -y
echo -en '\n'

echo -en "${GREEN}* Compile allsky software\n${NC}"
make all
echo -en '\n'

echo -en "${GREEN}* Sunwait installation"
cp sunwait /usr/local/bin
echo -en '\n'

echo -en "${GREEN}* Using the camera without root access\n${NC}"
install asi.rules /etc/udev/rules.d
udevadm control -R
echo -en '\n'

echo -en "${GREEN}* Autostart script\n${NC}"
sed -i '/allsky_RPiHQ.sh/d' /etc/xdg/lxsession/LXDE-pi/autostart
cp autostart/allsky_RPiHQ.service /lib/systemd/system/
chown root:root /lib/systemd/system/allsky_RPiHQ.service
chmod 0644 /lib/systemd/system/allsky_RPiHQ.service
echo -en '\n'

echo -en "${GREEN}* Configure log rotation\n${NC}"
cp autostart/allsky /etc/logrotate.d/
chown root:root /etc/logrotate.d/allsky
chmod 0644 /etc/logrotate.d/allsky
cp autostart/allsky.conf /etc/rsyslog.d/
chown root:root /etc/rsyslog.d/allsky.conf
chmod 0644 /etc/rsyslog.d/allsky.conf
echo -en '\n'

echo -en "${GREEN}* Copy camera settings files\n${NC}"
if ! -f 'settings.json' ] ; then
	cp settings_RPiHQ.json.repo settings.json
fi
if [ ! -f 'config.sh' ] ; then
	cp config_RPiHQ.sh.repo config.sh
fi
if [ ! -f 'scripts/ftp-settings.sh' ] ; then
	cp scripts/ftp-settings.sh.repo scripts/ftp-settings.sh
fi
echo -en '\n'

echo -en "${GREEN}* Change ownership of all files in allsky directory to pi:pi\n${NC}"
chown -R pi:pi /home/pi/allsky
echo -en '\n'

echo -en "${GREEN}* Start all sky service\n${NC}"
systemctl daemon-reload
systemctl enable allsky_RPiHQ.service
echo -en '\n'

echo -en "${GREEN}* Making sure all scripts in scripts directory are executable\n${NC}"
sudo chmod 755 /home/pi/allsky/scripts/*.sh
echo -en '\n'

echo -en "${GREEN}* Create image directory if it does not exist yet\n${NC}"
if [ ! -d '/home/pi/allsky/images' ] ; then
	mkdir /home/pi/allsky/images
	chown pi:pi /home/pi/allsky/images
fi
echo -en '\n'

echo -en '\n'
echo -en "The Allsky Software is now installed. You should reboot the Raspberry Pi to finish the installation\n"
echo -en '\n'
read -p "Do you want to reboot now? [y/n] " ans_yn
case "$ans_yn" in
  [Yy]|[Yy][Ee][Ss]) reboot now;;

  *) exit 3;;
esac
