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
