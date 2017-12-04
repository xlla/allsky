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

# Find current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Enter current directory
cd $DIR

echo -en '\n'
echo -e "${RED}****************************************************************"
echo    "*** Welcome to the Allsky Administration Portal installation ***"
echo -e "****************************************************************${NC}"
echo -en '\n'
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
echo -e "${GREEN}* Installation of the webserver${NC}"
echo -en '\n'
apt-get update && apt-get install -y lighttpd php-cgi hostapd dnsmasq avahi-daemon
lighty-enable-mod fastcgi-php
echo -en '\n'
echo -e "${GREEN}* Configuring lighttpd${NC}"
sed -i '/^dir-listing.activate/d' /etc/lighttpd/lighttpd.conf &&
sed -i '/^alias.url/d' /etc/lighttpd/lighttpd.conf &&
sed -i '/server.port                 = 80/a \\ndir-listing.activate = "enable"\nalias.url		    = ("/current/" => "'$(dirname $DIR)'/")\nalias.url		    += ("/images/" => "'$(dirname "$DIR")'/images/")\n' /etc/lighttpd/lighttpd.conf

echo -en '\n'
if [ "$arch" = "armv6" ] || [ "$arch" = "armv7" ]; then
	echo -e "${GREEN}* Changing hostname to allsky${NC}"
	echo "allsky" > /etc/hostname
	sed -i 's/raspberrypi/allsky/g' /etc/hosts
	echo -en '\n'
	echo -e "${GREEN}* Setting avahi-daemon configuration${NC}"
	cp avahi-daemon.conf /etc/avahi/avahi-daemon.conf
	echo -en '\n'
fi
echo -e "${GREEN}* Adding the right permissions to the web server${NC}"
cat sudoers >> /etc/sudoers
echo -en '\n'
echo -e "${GREEN}* Retrieving github files to build admin portal${NC}"
rm -rf /var/www/html
git clone https://github.com/thomasjacquin/allsky-portal.git /var/www/html
mkdir /etc/raspap
mv /var/www/html/raspap.php /etc/raspap/
chown -R www-data:www-data /etc/raspap
usermod -a -G www-data $SUDO_USER
echo -en '\n'
echo -e "${GREEN}* Modify config.sh${NC}"
printf "CAMERA_SETTINGS='/var/www/html/settings.json'\n" >> ../config.sh
chown -R $SUDO_USER:$SUDO_USER ../
cp ../settings.json /var/www/html/settings.json
echo -en '\n'
echo -e "${GREEN}* Restarting webserver${NC}"
chown -R www-data:www-data /var/www/html
service lighttpd restart
echo -en '\n'
echo -en "The Allsky Portal is now installed\n"
if [ "$arch" = "armv6" ] || [ "$arch" = "armv7" ]; then
	echo "You can now reboot the Raspberry Pi and connect to it from your laptop, computer, phone, tablet at this address: http://<raspberrypi_IP> (ex: http://192.168.0.10) or http://allsky.local"
	echo -en '\n'
	read -p "Do you want to reboot now? [y/n] " ans_yn
	case "$ans_yn" in
	  [Yy]|[Yy][Ee][Ss]) reboot now;;
	  *) exit 3;;
	esac
else
	echo -en "You can now access the portal in your browser at this address http://localhost or http://<your_IP> (ex: http://192.168.0.10) from another computer\n\n"
fi
