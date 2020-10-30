#!/bin/bash


#### installation du proxy authentifiant ####
# - evite les popup intempestive
# - ver 1.1.0
# - 26 Mai 2020
# - CALPETARD Olivier - AMI - lycee Antoine ROUSSIN
# - SEVERIN Didier - RRUPN - Collège Bois de Nèfles

#############################################
# Run using sudo, of course.
#############################################
if [ "$UID" -ne "0" ]
then
  echo "Il faut etre root pour executer ce script. ==> sudo "
  exit 
fi 

# Verification de la présence des fichiers contenant les fonctions et variables communes
if [ -e ./esub_functions.sh ]; then
  my_dir="$(dirname "$0")"
  source $my_dir/esub_functions.sh
elif [ -e ../esub_functions.sh ]; then
  source ../esub_functions.sh
else
  echo "Fichier esub_functions.sh absent ! Interruption de l'installation."
  exit
fi

#determiner le repertoire de lancement
updatedb
locate version_esubuntu.txt > files_tmp
sed -i -e "s/version_esubuntu.txt//g" files_tmp
read chemin < files_tmp
echo $chemin

#creation des parametres etablissement
echo "NOM_ETAB=\"$nom_etab\"" > "$chemin"esubuntu/param_etab.conf
echo "DOMAINENAME=\"$nom_domaine\"" >> "$chemin"esubuntu/param_etab.conf
echo "PROXY=\"$proxy\"" >> "$chemin"esubuntu/param_etab.conf
echo "NOPROXY=\"$proxy_env_noproxy\"" >> "$chemin"esubuntu/param_etab.conf
echo "PORTCNTLM=\"$port_cntlm\"" >> "$chemin"esubuntu/param_etab.conf
echo "TYPE_AUTH=\"$type_cntlm\"" >> "$chemin"esubuntu/param_etab.conf
echo "AIDE=\"$sos_info\"">> "$chemin"esubuntu/param_etab.conf

#installation de cntlm 
sudo apt-get install cntlm 

# copie des fichiers
sudo cp "$chemin"esubuntu/cntlm.sh /etc/esubuntu/
sudo cp "$chemin"esubuntu/reconf_cntlm.sh /etc/esubuntu/
sudo chmod +x /etc/esubuntu/*.sh
sudo cp "$chemin"xdg_autostart/cntlm.desktop /etc/xdg/autostart/
sudo chmod +x /etc/xdg/autostart/cntlm.desktop
sudo cp "$chemin"esubuntu/param_etab.conf /etc/esubuntu/
sudo chmod 755 /etc/esubuntu/param_etab.conf

#configuration de cntlm système pour ne pas faire d'interférence avec celui de lutilisateur

echo "Username	admin
Domain		$nom_domaine
Auth		$type_cntlm
Proxy		$proxy
NoProxy		$proxy_env_noproxy
Listen		3129" > /etc/cntlm.conf


echo "penser a modifier les paramétre proxy dans firefox.js et dans gset par 127.0.0.1:$port_cntlm"
writelog "penser a modifier les paramétre proxy dans firefox.js et dans gset par 127.0.0.1:$port_cntlm"
exit
