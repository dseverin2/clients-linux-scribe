#!/bin/sh
# Script original de Didier SEVERIN (25/02/20)

sudo apt install ffmpeg
sudo apt install gdebi
wget https://github.com/OpenBoard-org/OpenBoard/releases/download/v1.6.0a/openboard_ubuntu_20.04_1.6.0-a.0_amd64.deb
wget http://fr.archive.ubuntu.com/ubuntu/pool/main/p/poppler/libpoppler90_0.80.0-0ubuntu1.1_amd64.deb
sudo gdebi libpoppler90_0.80.0-0ubuntu1.1_amd64.deb
sudo gdebi openboard_ubuntu_20.04_1.6.0-a.0_amd64.deb
