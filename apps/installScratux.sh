#!/bin/bash
# Verification de la présence des fichiers contenant les fonctions et variables communes
if [ -e ./esub_functions.sh ]; then
	source ./esub_functions.sh
elif [ -e ../esub_functions.sh ]; then
	source ../esub_functions.sh
else
	echo "Fichier esub_functions.sh absent ! Interruption de l'installation."
	exit
fi

getversion

#18.04
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61
echo "deb [arch=amd64 trusted=yes] https://dl.bintray.com/scratux/stable" $version "main" | sudo tee /etc/apt/sources.list.d/scratux.list
sudo apt-get update
sudo apt-get install scratux
