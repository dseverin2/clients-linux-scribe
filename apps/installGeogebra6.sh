#!/bin/sh
# Script original de Didier SEVERIN (13/05/20)

apt-add-repository -u 'deb http://www.geogebra.net/linux/ stable main' 
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C072A32983A736CF  &&   sudo apt-get update
apt install geogebra-classic -y
apt --fix-missing install -y
apt install geogebra-classic -y
