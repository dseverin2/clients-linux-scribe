#!/bin/sh
# v1.0 - 11.10.20
# Didier SEVERIN

# Ajout du dépot application ActivBoard
echo "deb [arch=amd64] http://activsoftware.co.uk/linux/repos/ubuntu bionic non-oss" | tee /etc/apt/sources.list.d/promethean-activboard.list

# Ajout du dépot drivers ActivDriver & ActivTools
echo "deb http://activsoftware.co.uk/linux/repos/driver/ubuntu bionic oss non-oss" | tee /etc/apt/sources.list.d/promethean-activdriver.list
wget http://activsoftware.co.uk/linux/repos/driver/PrometheanLtd.asc
apt-key add ./PrometheanLtd.asc

# Installation de libssl
wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl1.0/libssl1.0.0_1.0.2n-1ubuntu5.4_amd64.deb
dpkg -i libssl1.0.0_1.0.2n-1ubuntu5.4_amd64.deb

# Installation de libcurl 3 et 4
add-apt-repository ppa:xapienz/curl34 -y
apt update
apt install curl -y

# Installation des librairies utilisées au lancement d'ActivInspire
wget http://security.ubuntu.com/ubuntu/pool/main/i/icu/libicu60_60.2-3ubuntu3.1_amd64.deb
sudo dpkg -i libicu60_60.2-3ubuntu3.1_amd64.deb
sudo apt-get install gsettings-ubuntu-schemas

# Installation
apt install activdriver activtools -y
apt install activ-meta-fr -y
apt install --fix-broken -y
apt autoremove -y

# Nettoyage
sudo rm -f libssl*.deb libicu*.deb PrometheanLtd.asc

# Compilation du driver pour les ActivBoard de 1ère et 2ème génération
read -p "Cet ordinateur sera-t-il connecté à un ActivBoard de 1ère ou 2ème génération ? O/N " reponse
if [ "$reponse"=="o" ] || [ "$reponse"=="O" ]; then
  echo "Compilation des drivers"
  sed -i -e "s/SUBDIRS/M/g" /usr/src/promethean/kernel/Makefile
  cd /usr/src/promethean/kernel/
  ./b
fi
