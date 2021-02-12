#!/bin/sh
# Script original de Didier SEVERIN (13/05/20)
wget -qO - https://static.geogebra.org/linux/office@geogebra.org.gpg.key | sudo apt-key add -
echo 'deb http://www.geogebra.net/linux/ stable main' | tee /etc/apt/sources.list.d/geogebra-classic.list 
sudo apt-get update
apt install geogebra-classic -y
