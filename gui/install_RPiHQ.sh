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
apt-get update && apt-get install -y lighttpd php7.3-cgi hostapd dnsmasq avahi-daemon
lighty-enable-mod fastcgi-php
service lighttpd restart
echo -en '\n'

echo -e "${GREEN}* Configuring lighttpd${NC}"
cp ~/allsky/gui/lighttpd.conf /etc/lighttpd/lighttpd.conf
echo -en '\n'

echo -e "${GREEN}* Changing hostname to allsky${NC}"
echo "allsky" > /etc/hostname
sed -i 's/raspberrypi/allsky/g' /etc/hosts
echo -en '\n'

echo -e "${GREEN}* Setting avahi-daemon configuration${NC}"
cp ~/allsky/gui/avahi-daemon.conf /etc/avahi/avahi-daemon.conf
echo -en '\n'

echo -e "${GREEN}* Adding the right permissions to the web server${NC}"
sed -i '/allsky/d' /etc/sudoers
sed -i '/www-data/d' /etc/sudoers
rm -f /etc/sudoers.d/allsky
cat ~/allsky/gui/sudoers >> /etc/sudoers.d/allsky
echo -en '\n'

echo -e "${GREEN}* Retrieving github files to build admin portal${NC}"
rm -rf /var/www/html
git clone https://github.com/thomasjacquin/allsky-portal.git /var/www/html
chown -R www-data:www-data /var/www/html
mkdir /etc/raspap
mv /var/www/html/raspap.php /etc/raspap/
mv /var/www/html/camera_options.json /etc/raspap/
cp ~/allsky/settings.json /etc/raspap/settings_RPiHQ.json
chown -R www-data:www-data /etc/raspap
usermod -a -G www-data pi
echo -en '\n'

echo -e "${GREEN}* Modify config.sh${NC}"
sed -i '/CAMERA_SETTINGS=/c\CAMERA_SETTINGS="/etc/raspap/settings_RPiHQ.json"' ~/allsky/config.sh
echo -en '\n'

echo -e "${GREEN}* Put adjusted RPI HQ camera options file in place${NC}"
mv /etc/raspap/camera_options.json /etc/raspap/camera_options_RPiHQ.json
mv /etc/raspap/camera_options_RPiHQ.json /etc/raspap/camera_options_RPiHQ.json.org
cp ~/allsky/camera_options.json /etc/raspap/camera_options_RPiHQ.json
chown www-data:www-data /etc/raspap/camera_options_RPiHQ.json
chmod 644 /etc/raspap/camera_options_RPiHQ.json
echo -en '\n'

echo -e "${GREEN}* Replace restartCapture.sh with adjusted RPI HQ camera version${NC}"
cp ~/allsky/restartCapture.sh /var/www/html
chmod 755 /var/www/html/restartCapture.sh
#rm ~/allsky/restartCapture.sh
echo -en '\n'

echo -e "${GREEN}* Replace system.php and camera_options.php files with adjusted RPI HQ camera version${NC}"
#sudo cp ~/allsky/gui/system.php /var/www/html/includes
#sudo chown www-data:www-data /var/www/html/includes/system.php
sudo cp ~/allsky/gui/camera_settings.php /var/www/html/includes
sudo chown www-data:www-data /var/www/html/includes/camera_settings.php
cd /var/www/html
sudo ln -s /home/pi/allsky current

echo -en '\n'

echo "The Allsky Portal is now installed"
echo "You can now reboot the Raspberry Pi and connect to it from your laptop, computer, phone, tablet at this address: http://allsky.local"
echo -en '\n'
read -p "Do you want to reboot now? [y/n] " ans_yn
case "$ans_yn" in
  [Yy]|[Yy][Ee][Ss]) reboot now;;

  *) exit 3;;
esac
