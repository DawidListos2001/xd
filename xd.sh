#!/bin/bash
#Copyright © 2015 Michał Frąckiewicz. All rights reserved.
set -e
clear
echo "Aimpanel installer v1.25"
#
echo ""
#
if [ ! -x  /usr/bin/lsb_release ]
then
    echo -e "\e[32mInstalling missing system package\e[0m"
    apt-get update && apt-get -y install lsb-release
fi
#
echo "Detected $(lsb_release -is) $(lsb_release -rs) $(lsb_release -cs) - OK"
fi
#
if [ `getconf LONG_BIT` = "64" ]
then
    echo "Detected 64bit OS - OK"
else
    echo "32bit OS are not supported yet"
    exit 1
fi
#
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root!" 1>&2
   exit 1
fi
#
while true; do
    echo ""
    echo "http://aimpanel.pro/LICENSE_EN/"
    read -p "Do you accept EULA terms? Yes/No: " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Type Yes or No";;
    esac
done
#
echo -e "\e[32mStarting installation, it should take about 5 minutes\e[0m"
#
echo -e "\e[32mAdding Aimpanel trusted key\e[0m"
wget -O - http://repo.aimpanel.pro/deb/repo.gpg.key | apt-key add -
#
echo -e "\e[32mAdding Aimpanel repository\e[0m"
#
if [ `getconf LONG_BIT` = "64" ]
then
    echo "deb [arch=amd64] http://repo.aimpanel.pro/deb/wheezy wheezy main" > /etc/apt/sources.list.d/aimpanel.list
else
    echo "deb [arch=i386] http://repo.aimpanel.pro/deb/wheezy wheezy main" > /etc/apt/sources.list.d/aimpanel.list
fi
#
echo -e "\e[32mUpdating repo packages list\e[0m"
apt-get update
#
echo -e "\e[32mInstalling Aimpanel and stuff\e[0m"
apt-get install -y sudo psmisc gawk procps mawk
apt-get install -y aimpanel-app openjdk-7-jre-headless
sudo -u aimpanel /usr/local/aimpanel/app/artisan selfheal:check
clear
echo "Aimpanel installed!"
echo ""
echo -e "\e[32mRemember to enter your product key via command:\e[0m aimpanel key set \e[1myour_key\e[0m"
echo "Open http://your-server-address.com:3131 in your browser"
sudo -u aimpanel /usr/local/aimpanel/app/artisan admin:create
#
service ssh restart &>> aimpanel_install.log
