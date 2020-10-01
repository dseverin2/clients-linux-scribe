#!/bin/sh
# Ajout du dépot application ActivBoard
echo deb http://activsoftware.co.uk/linux/repos/ubuntu bionic non-oss >> /etc/apt/sources.list
wget http://activsoftware.co.uk/linux/repos/driver/PrometheanLtd.asc
apt-key add ./PrometheanLtd.asc
rm -fr ./PrometheanLtd.asc

# Ajout du dépot drivers ActivDriver & ActivTools
echo deb http://activsoftware.co.uk/linux/repos/driver/ubuntu bionic oss non-oss >> /etc/apt/sources.list
wget http://activsoftware.co.uk/linux/repos/driver/PrometheanLtd.asc
apt-key add ./PrometheanLtd.asc
rm -fr ./PrometheanLtd.asc


# Installation
apt update
apt install activdriver activtools
apt install activ-meta-fr -y
apt --fix-broken install -y
apt autoremove

# Rendre ActivInspire fonctionnel
wget http://security.ubuntu.com/ubuntu/pool/main/i/icu/libicu60_60.2-3ubuntu3.1_amd64.deb
sudo dpkg -i libicu60_60.2-3ubuntu3.1_amd64.deb
sudo apt-get install gsettings-ubuntu-schema

# Rendre ActivDriver fonctionnel / Nécessite le downgrade vers 4.19
#cd /tmp/
#wget -c http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.19/linux-headers-4.19.0-041900_4.19.0-041900.201810221809_all.deb
#wget -c http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.19/linux-headers-4.19.0-041900-generic_4.19.0-041900.201810221809_amd64.deb
#wget -c http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.19/linux-image-unsigned-4.19.0-041900-generic_4.19.0-041900.201810221809_amd64.deb
#wget -c http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.19/linux-modules-4.19.0-041900-generic_4.19.0-041900.201810221809_amd64.deb
#sudo dpkg -i *.deb
