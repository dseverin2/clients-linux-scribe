#!/bin/bash

# Verification de la présence des fichiers contenant les fonctions et variables communes
if [ -e ./esub_functions.sh ]; then
  source ./esub_functions.sh
else
  echo "Fichier esub_functions.sh absent ! Interruption de l'installation."
  exit
fi

writelog "INITBLOC" "Mise en place du proxy"
#############################################
# Modification du /etc/wgetrc.
#############################################
writelog "0-Paramétrage du proxy dans /etc/wgetrc"
if grep "use_proxy=on" /etc/wgetrc; then
	sed '/[ht|f]tps\?_proxy*/d' /etc/wgetrc | tee /etc/wgetrc  # Nettoyage en cas de réintégration directe
fi
addtoend /etc/wgetrc "" "https_proxy = $proxy_wgetrc" "http_proxy = $proxy_wgetrc" "ftp_proxy = $proxy_wgetrc" "use_proxy=on" "proxy-user = $scribeuserapt" "proxy-password = $scribepass"  2>> $logfile
#######################################################
#Paramétrage des paramètres Proxy pour tout le système
#######################################################
if [[ $proxy_def_ip != "" ]] || [[ $proxy_def_port != "" ]]; then
	writelog "INITBLOC" "Paramétrage du proxy $proxy_def_ip:$proxy_def_port" 
	
	#Paramétrage des paramètres Proxy pour Gnome
	#######################################################
	writelog "---Inscription du proxy dans le schéma de gnome"
	echo "[org.gnome.system.proxy]
mode='manual'
use-same-proxy=true
ignore-hosts=$proxy_gnome_noproxy
[org.gnome.system.proxy.http]
host='$proxy_def_ip'
port=$proxy_def_port
[org.gnome.system.proxy.https]
host='$proxy_def_ip'
port=$proxy_def_port" > /usr/share/glib-2.0/schemas/my-defaults.gschema.override 2>> $logfile

	  glib-compile-schemas /usr/share/glib-2.0/schemas 2>> $logfile

	#Paramétrage du Proxy pour le système
	######################################################################
	writelog "---Inscription du proxy dans /etc/environment"
	sed '/[h|f|n][a-z]*_proxy*/d' /etc/environment | tee /etc/environment # Nettoyage en cas de réintégration directe
	addtoend /etc/environment "http_proxy=http://$proxy_def_ip:$proxy_def_port/" "https_proxy=http://$proxy_def_ip:$proxy_def_port/" "ftp_proxy=http://$proxy_def_ip:$proxy_def_port/" "no_proxy=\"$proxy_env_noproxy\"" 2>> $logfile

	#Paramétrage du Proxy pour apt
	######################################################################
	writelog "---Inscription du proxy pour apt"
	echo "APT::Get::AllowUnauthenticated 1;
Acquire::http::proxy \"http://$scribeuserapt:$scribepass@$proxy_def_ip:$portapt/\";
Acquire::ftp::proxy \"ftp://$scribeuserapt:$scribepass@$proxy_def_ip:$portapt/\";
Acquire::https::proxy \"https://$scribeuserapt:$scribepass@$proxy_def_ip:$portapt/\";" > /etc/apt/apt.conf.d/20proxy 2>>$logfile

	#Permettre d'utiliser la commande add-apt-repository derrière un Proxy
	######################################################################
	writelog "---Autorisation de la commande add-apt-repository derrière un proxy"
	addtoend /etc/sudoers "Defaults env_keep = https_proxy" 2>> $logfile
	
	#Paramétrage du Proxy pour snap
	######################################################################
	if [ -e /etc/apt/preferences.d/nosnap.pref ]; then 
		rm -f /etc/apt/preferences.d/nosnap.pref
		apt update
	fi
	apt install snapd -y
	snap set system proxy.http="http://$proxy_def_ip:$proxy_def_port"
	snap set system proxy.https="http://$proxy_def_ip:$proxy_def_port"
fi

# Modification pour ne pas avoir de problème lors du rafraichissement des dépots avec un proxy
# cette ligne peut être commentée/ignorée si vous n'utilisez pas de proxy ou avec la 14.04.
writelog "---Patch de /etc/apt/apt.conf pour empêcher les erreurs de rafraichissement des dépots"
addtoend /etc/apt/apt.conf "Acquire::http::No-Cache true;" "Acquire::http::Pipeline-Depth 0;" 2>> $logfile

writelog "ENDBLOC"
