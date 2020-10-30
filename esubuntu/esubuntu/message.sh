#!/bin/bash

#### chargement d'un message l'ouverture de session ubuntu ####
# - récupère le message sur le serveur scribe
# - ver 1.0.1
# - 01 Avril 2015
# - CALPETARD Olivier

gm_esu=grp_eole
#les fichiers se trouvent dans icones$ 
#lecture du groupe ESU
if [ -f "/etc/GM_ESU" ];then
echo "Le PC est dans le groupe esu"
gm_esu=$(cat /etc/GM_ESU)
fi

#affiche le message oui ou non
affiche=$(cat /tmp/netlogon/icones/$gm_esu/linux/message/affiche.txt)

if [ $affiche = oui ]
	then
	cp /tmp/netlogon/icones/$gm_esu/linux/message/message.txt $HOME/
	zenity --title INFORMATION --width=550 --height=500 --text-info --filename $HOME/message.txt
	
	else
	exit 0
fi



