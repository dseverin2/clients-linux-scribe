#!/bin/bash
# version 1.0 (30/10/20)
# Didier SEVERIN (Académie de la Réunion)


wget -q http://fr.archive.ubuntu.com/ubuntu/pool/universe/g/glew/libglew2.1_2.1.0-4_amd64.deb
apt install --no-install-recommends ./libglew2.1_2.1.0-4_amd64.deb -y
rm -v libglew2.1_2.1.0-4_amd64.deb
wget -O- https://bintray.com/user/downloadSubjectPublicKey?username=bintray | apt-key add -

# A remplacer par focal dès l'existence d'un fichier release :
echo "deb https://dl.bintray.com/celestia/releases-deb bionic universe" | sudo tee /etc/apt/sources.list.d/celestia-obs.list
apt update 
apt install celestia -y
