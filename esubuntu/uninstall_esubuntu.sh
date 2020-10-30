#!/bin/bash


#### désinstallation de esubuntu ####
# - ver 1.0.0
# - 25 Mai 2018
# - CALPETARD Olivier - AMI - lycee Antoine ROUSSIN

#############################################
# Run using sudo, of course.
#############################################
if [ "$UID" -ne "0" ]
then
  echo "Il faut etre root pour executer ce script. ==> sudo "
  exit 
fi 

# Uniquement pour le cas ou Esubuntu a été installé 
echo "suppression des logiciels installés"

apt-get remove -y zenity conky
rm -rf /usr/local/upkg_client

echo "suppressions des fichiers de configuration"
rm -f /etc/xdg/autostart/message_scribe.desktop
rm -f /etc/xdg/autostart/scribe_background.desktop
rm -f /etc/xdg/autostart/cntlm.desktop
rm -f /etc/GM_ESU
rm -rf /etc/esubuntu
echo "modification de la tache planifié upkg"
echo "" > /etc/crontab #remplacement du contenu d'esubuntu par du contenu vide

#modification firefox
echo "modification de firefox"
echo "//" > /etc/firefox/syspref.js 
rm -f /usr/lib/firefox/firefox.cfg

exit
