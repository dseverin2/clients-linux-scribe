#!/bin/sh
# Script original de Didier SEVERIN (16/09/20)

#INSTALLATION DES POLICES
wget http://download.tuxfamily.org/polyglotte/archives/msfonts-config2.zip
unzip msfonts-config2.zip -o -d /etc/fonts/
unzip WPS\ Office/winfonts.zip -o -d /usr/share/fonts/winfonts/
rm -fr msfonts-config2.zip
apt-get install gsfonts gsfonts-other gsfonts-x11 ttf-mscorefonts-installer t1-xfree86-nonfree fonts-alee ttf-ancient-fonts fonts-arabeyes fonts-arphic-bkai00mp fonts-arphic-bsmi00lp fonts-arphic-gbsn00lp fonts-arphic-gkai00mp fonts-atarismall fonts-dustin fonts-f500 fonts-sil-gentium ttf-georgewilliams ttf-isabella fonts-larabie-deco fonts-larabie-straight fonts-larabie-uncommon ttf-sjfonts ttf-staypuft ttf-summersby fonts-ubuntu-title ttf-xfree86-nonfree xfonts-intl-european xfonts-jmk xfonts-terminus fonts-liberation ubuntu-restricted-extras -y

#INSTALLATION DE WPS
build="9615"
version="11.1.0."$build

# Logiciel
wget http://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/$build/wps-office_$version.XA_amd64.deb
dpkg -i wps-office_$version.XA_amd64.deb
# Dictionnaire FR
wget https://github.com/wps-community/wps_community_website/raw/master/root/download/dicts/fr_FR.zip
unzip -u fr_FR.zip -o -d /opt/kingsoft/wps-office/office6/dicts/spellcheck/
# Interface FR
sudo apt install p7zip p7zip-full -y
wget https://github.com/timxx/wps-office-mui/raw/master/mui/fr_FR.7z
7z x fr_FR.7z -o/opt/kingsoft/wps-office/office6/mui/ -aoa
#rm -fr /opt/kingsoft/wps-office/office6/mui/en_US 
#rm -fr /opt/kingsoft/wps-office/office6/mui/ug_CN
cp -fr /opt/kingsoft/wps-office/office6/mui/fr_FR/* /opt/kingsoft/wps-office/office6/mui/ug_CN/
cp -fr /opt/kingsoft/wps-office/office6/mui/fr_FR/* /opt/kingsoft/wps-office/office6/mui/en_US/
rm -f wps-office_$version.XA_amd64.deb fr_FR.zip fr_FR.7z
