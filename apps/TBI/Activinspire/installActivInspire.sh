#!/bin/sh
# Ajout du dépot
echo deb http://activsoftware.co.uk/linux/repos/ubuntu bionic non-oss >> /etc/apt/sources.list
wget http://activsoftware.co.uk/linux/repos/driver/PrometheanLtd.asc
apt-key add ./PrometheanLtd.asc
rm -fr ./PrometheanLtd.asc

# Installation
apt update
apt install activ-meta-fr -y
apt --fix-broken install -y
apt autoremove
