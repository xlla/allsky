#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
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
apt-get update && apt-get install -y lighttpd php php-cli php-cgi php-fpm hostapd dnsmasq avahi-daemon lighttpd-module-alias lighttpd-module-fastcgi lighttpd-module-redirect lighttpd-module-compress
#lighttpd-enable-mod fastcgi-php
systemctl restart lighttpd
echo -en '\n'

echo -e "${GREEN}* Configuring lighttpd${NC}"
cp /home/pi/allsky/gui/lighttpd.conf /etc/lighttpd/lighttpd.conf
echo -en '\n'

#echo -e "${GREEN}* Changing hostname to allsky${NC}"
#echo "allsky" > /etc/hostname
#sed -i 's/raspberrypi/allsky/g' /etc/hosts
#echo -en '\n'

echo -e "${GREEN}* Setting avahi-daemon configuration${NC}"
cp /home/pi/allsky/gui/avahi-daemon.conf /etc/avahi/avahi-daemon.conf
echo -en '\n'

echo -e "${GREEN}* Adding the right permissions to the web server${NC}"
sed -i '/allsky/d' /etc/sudoers
sed -i '/www-data/d' /etc/sudoers
rm -f /etc/sudoers.d/allsky
cat /home/pi/allsky/gui/sudoers >> /etc/sudoers.d/allsky
echo -en '\n'

echo -e "${GREEN}* Retrieving github files to build admin portal${NC}"
rm -rf /var/www/html
#git clone https://github.com/thomasjacquin/allsky-portal.git /var/www/html
#tar xzf /home/pi/git/allsky-portal.tar.gz -C /var/www
#mv /var/www/allsky-portal /var/www/html
cp -r /home/pi/git/allsky-portal /var/www/
mv /var/www/allsky-portal /var/www/html
chown -R www-data:www-data /var/www/html
mkdir /etc/raspap
mv /var/www/html/raspap.php /etc/raspap/
chown -R www-data:www-data /etc/raspap
usermod -a -G www-data pi
mkdir -p /var/cache/lighttpd/uploads/
mkdir -p /var/cache/lighttpd/compress/
mkdir /var/log/lighttpd
mkdir /var/cache/lighttpd
chown -R www-data:www-data /var/cache/lighttpd
chown -R www-data:www-data /var/log/lighttpd
echo -en '\n'

echo -e "${GREEN}* Modify config.sh${NC}"
sed -i '/CAMERA_SETTINGS=/c\CAMERA_SETTINGS="/etc/raspap/settings_RPiHQ.json"' /home/pi/allsky/config.sh
echo -en '\n'

echo -e "${GREEN}* Put adjusted RPI HQ camera options & settings file in place${NC}"
if [ -f '/etc/raspap/camera_options.json' ] ; then
	sudo mv /etc/raspap/camera_options.json /etc/raspap/camera_options_RPiHQ.json
fi

if [ -f '/etc/raspap/camera_options_RPiHQ.json' ] ; then
	sudo mv /etc/raspap/camera_options_RPiHQ.json /etc/raspap/camera_options_RPiHQ.json.org
fi

sudo cp /home/pi/allsky/camera_options_RPiHQ.json.repo /etc/raspap/camera_options_RPiHQ.json
sudo chown www-data:www-data /etc/raspap/camera_options_RPiHQ.json
sudo chmod 644 /etc/raspap/camera_options_RPiHQ.json

if [ -f '/etc/raspap/setting.json' ] ; then
	sudo mv /etc/raspap/setting.json /etc/raspap/settings_RPiHQ.json
fi

if [ -f '/etc/raspap/settings_RPiHQ.json' ] ; then
	sudo mv /etc/raspap/settings_RPiHQ.json /etc/raspap/settings_RPiHQ.json.org
fi

sudo cp /home/pi/allsky/settings_RPiHQ.json.repo /etc/raspap/settings_RPiHQ.json
sudo chown www-data:www-data /etc/raspap/settings_RPiHQ.json
sudo chmod 664 /etc/raspap/settings_RPiHQ.json
echo -en '\n'

echo -e "${GREEN}* Replace system.php, days.php, editor.php and camera_settings.php files with adjusted RPI HQ camera version${NC}"
sudo cp /home/pi/allsky/system.php /var/www/html/includes
sudo chown www-data:www-data /var/www/html/includes/system.php

sudo cp /home/pi/allsky/camera_settings.php /var/www/html/includes
sudo chown www-data:www-data /var/www/html/includes/camera_settings.php

sudo cp /home/pi/allsky/editor.php /var/www/html/includes
sudo chown www-data:www-data /var/www/html/includes/editor.php

sudo cp /home/pi/allsky/days.php /var/www/html/includes
sudo chown www-data:www-data /var/www/html/includes/days.php
echo -en '\n'

cd /var/www/html
echo -e "${GREEN}* Create softlink current to /home/pi/allsky/images${NC}"
sudo cp img/allsky-favicon.png /home/pi/allsky/images/favicon.png
sudo chown pi:pi /home/pi/allsky/images/favicon.png
sudo rm -rf /var/www/html/images
sudo ln -s /home/pi/allsky/images images
echo -en '\n'

echo -e "${GREEN}* Create softlink current to /home/pi/allsky${NC}"
sudo ln -s /home/pi/allsky current
echo -en '\n'

chown -R pi:www-data /var/www/html/current
chown -R pi:www-data /var/www/html/images

#echo -e "${GREEN}* Add www-data user to the sudo group${NC}"
#sudo adduser www-data sudo
#echo -en '\n'

echo "The Allsky Portal is now installed"
echo "You can now reboot the Raspberry Pi and connect to it from your laptop, computer, phone, tablet at this address: http://allsky.local"
echo -en '\n'
read -p "Do you want to reboot now? [y/n] " ans_yn
case "$ans_yn" in
  [Yy]|[Yy][Ee][Ss]) reboot now;;

  *) exit 3;;
esac
