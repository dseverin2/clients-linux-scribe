#!/bin/sh

# Test Root
if [ $(id -u) -ne 0 ]; then                       
    echo "Vous devez être root pour lancer ce script" >&2
    exit 1
fi

# Installation des packets arduino
apt update
apt-get install -y arduino

# Installation de mBlock 4.0.4 (après récupération du .deb)
apt-get -y install libgconf-2-4 
if [ ! -e ./mBlock_4.0.4_amd64.deb ]; then
	wget "$wgetparams" --no-check-certificate http://mblock.makeblock.com/mBlock4.0/mBlock_4.0.4_amd64.deb
fi
if [ ! -e ./mLink-1.2.0-amd64.deb ]; then
	wget "$wgetparams" --no-check-certificate https://dl.makeblock.com/mblock5/linux/mLink-1.2.0-amd64.deb
fi
dpkg -i ./mBlock_4.0.4_amd64.deb
dpkg -i ./mLink-1.2.0-amd64.deb
apt install -fy

rm -f mBlock_4.0.4_amd64.deb mLink-1.2.0-amd64.deb

# Installation des librairies manquantes
apt-get install libpangoft2-1.0-0 libpangocairo-1.0-0 libpango-1.0-0 -y
unzip mBlock.zip -d /opt/makeblock/mBlock

#Installation des librairies pour arduino
cd /usr/share/arduino/lib || exit
wget https://github.com/Makeblock-official/Makeblock-Libraries/archive/master.zip
unzip master.zip



