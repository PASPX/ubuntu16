#!/bin/bash
set -e

# set defaults
default_hostname="$(hostname)"
default_domain="netson.local"
default_puppetmaster="foreman.netson.nl"
tmp="/root/"

clear

# check for root privilege
if [ "$(id -u)" != "0" ]; then
   echo " this script must be run as root" 1>&2
   echo
   exit 1
fi

# define download function
# courtesy of http://fitnr.com/showing-file-download-progress-using-wget.html
download()
{
    local url=$1
    echo -n "    "
    wget --progress=dot $url 2>&1 | grep --line-buffered "%" | \
        sed -u -e "s,\.,,g" | awk '{printf("\b\b\b\b%4s", $2)}'
    echo -ne "\b\b\b\b"
    echo " DONE"
}

# determine ubuntu version
ubuntu_version=$(lsb_release -cs)

# check for interactive shell
if ! grep -q "noninteractive" /proc/cmdline ; then
    stty sane

    # ask questions
    read -ep " please enter your preferred hostname: " -i "$default_hostname" hostname
    read -ep " please enter your preferred domain: " -i "$default_domain" domain
fi

# print status message
echo " preparing your server; this may take a few minutes ..."

# set fqdn
fqdn="$hostname.$domain"

# update hostname
echo "$hostname" > /etc/hostname
sed -i "s@ubuntu.ubuntu@$fqdn@g" /etc/hosts
sed -i "s@ubuntu@$hostname@g" /etc/hosts
hostname "$hostname"

# update repos
apt-get -y update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get -y autoremove
apt-get -y purge

#Install Stuff
apt-get -y install dnsutils
apt-get -y install python3-gdbm
apt-get -y install ufw
apt-get -y install dosfstools
apt-get -y install ed
apt-get -y install telnet
apt-get -y install powermgmt-base
apt-get -y install ntfs-3g
apt-get -y install ubuntu-release-upgrader-core
apt-get -y install iputils-tracepath
apt-get -y install python3-update-manager
apt-get -y install groff-base
apt-get -y install python3-distupgrade
apt-get -y install bind9-host
apt-get -y install mtr-tiny
apt-get -y install bash-completion
apt-get -y install mlocate
apt-get -y install tcpdump
apt-get -y install geoip-database
apt-get -y install install-info
apt-get -y install irqbalance
apt-get -y install language-selector-common
apt-get -y install friendly-recovery
apt-get -y install command-not-found
apt-get -y install info
apt-get -y install hdparm
apt-get -y install man-db
apt-get -y install lshw
apt-get -y install update-manager-core
apt-get -y install apt-transport-https
apt-get -y install accountsservice
apt-get -y install command-not-found-data
apt-get -y install python3-commandnotfound
apt-get -y install time
apt-get -y install ltrace
apt-get -y install parted
apt-get -y install popularity-contest
apt-get -y install strace
apt-get -y install ftp
apt-get -y install ubuntu-standard
apt-get -y install lsof

#Enable UFW
ufw allow from 192.168.55.0/24 to any port 22
ufw allow from 192.168.77.0/24 to any port 22
ufw enable

#Webmin
echo "deb http://download.webmin.com/download/repository sarge contrib"
tee -a /etc/apt/sources.list
wget http://www.webmin.com/jcameron-key.asc
apt-key add jcameron-key.asc
apt-get update
apt-get -y install webmin
ufw allow from 192.168.77.0/24 to any port 10000
ufw allow from 192.168.55.0/24 to any port 10000

# remove myself to prevent any unintended changes at a later stage
rm $0

# finish
echo " DONE; rebooting ... "

# reboot
reboot
