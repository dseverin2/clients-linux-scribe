#!/bin/sh
# Script original de Didier SEVERIN (25/05/20)
# Mettre winfonts.zip sur git

#INSTALLATION DES POLICES
apt-get install gsfonts gsfonts-other gsfonts-x11 ttf-mscorefonts-installer t1-xfree86-nonfree fonts-alee ttf-ancient-fonts fonts-arabeyes fonts-arphic-bkai00mp fonts-arphic-bsmi00lp fonts-arphic-gbsn00lp fonts-arphic-gkai00mp fonts-atarismall fonts-dustin fonts-f500 fonts-sil-gentium ttf-georgewilliams ttf-isabella fonts-larabie-deco fonts-larabie-straight fonts-larabie-uncommon ttf-sjfonts ttf-staypuft ttf-summersby fonts-ubuntu-title ttf-xfree86-nonfree xfonts-intl-european xfonts-jmk xfonts-terminus -y
wget http://download.tuxfamily.org/polyglotte/archives/msfonts-config2.zip
unzip msfonts-config2.zip -d /etc/fonts/
unzip WPS\ Office/winfonts.zip -d /usr/share/fonts/winfonts/
rm -fr msfonts-config2.zip

#INSTALLATION DE WPS
# Logiciel
wget http://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/9505/wps-office_11.1.0.9505.XA_amd64.deb
dpkg -i wps-office_11.1.0.9505.XA_amd64.deb
# Dictionnaire FR
wget https://github.com/wps-community/wps_community_website/raw/master/root/download/dicts/fr_FR.zip
unzip -u fr_FR.zip -d /opt/kingsoft/wps-office/office6/dicts/spellcheck/
# Interface FR
sudo apt install p7zip p7zip-full -y
wget https://github.com/timxx/wps-office-mui/raw/master/mui/fr_FR.7z
7z x fr_FR.7z -o/opt/kingsoft/wps-office/office6/mui/
rm -f wps-office_11.1.0.9505.XA_amd64.deb fr_FR.zip fr_FR.7z
