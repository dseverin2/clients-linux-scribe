#!/bin/bash
# Script original de Didier SEVERIN (25/02/20)

sudo apt install gdebi ffmpeg
sudo apt update

if [ "$version" = "focal" ]; then
	wget https://github.com/OpenBoard-org/OpenBoard/releases/download/v1.6.0a/openboard_ubuntu_20.04_1.6.0-a.0_amd64.deb
	wget http://fr.archive.ubuntu.com/ubuntu/pool/main/p/poppler/libpoppler90_0.80.0-0ubuntu1.1_amd64.deb
	sudo gdebi -n libpoppler90_0.80.0-0ubuntu1.1_amd64.deb
	sudo gdebi -n openboard_ubuntu_20.04_1.6.0-a.0_amd64.deb
elif [ "$version" = "bionic" ]; then
	echo "deb http://fr.archive.ubuntu.com/ubuntu/ xenial main" | tee /etc/apt/sources.list.d/openboard.list
	echo "deb http://fr.archive.ubuntu.com/ubuntu/ xenial universe" | tee -a /etc/apt/sources.list.d/openboard.list
	echo "deb http://fr.archive.ubuntu.com/ubuntu/ xenial-updates universe" | tee -a /etc/apt/sources.list.d/openboard.list
	sudo apt update
	sudo apt install libavformat-ffmpeg56 -y
	wget https://github.com/OpenBoard-org/OpenBoard/releases/download/v1.5.4/openboard_ubuntu_16.04_1.5.4_amd64.deb
	sudo gdebi -n openboard_ubuntu_16.04_1.5.4_amd64.deb
	rm -f /etc/apt/sources.list.d/openboard.list
fi
