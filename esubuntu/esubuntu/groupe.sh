#!/bin/bash

#### utilitaire pour upkg ####
# - récupère la valeur du groupe et execute upkg_client si 
# - ver 2.1
# - 24 octobre 2020
# - CALPETARD Olivier
# - SEVERIN Didier

#administratif = 10000
#prof = 10001
#eleve = 10002
groupe=$GROUPS
netlogonIcons="/tmp/netlogon/icones"
logfile="/tmp/esubupkg.log"

echo `date` > $logfile
case $groupe in
10000)
	usergrp="administratif"
	;;
10001)
	usergrp="prof"
	;;
10002)
	usergrp="élève"
	;;
*)
	usergrp="undefined"
	;;
esac
echo "Groupe trouvé : $usergrp" >> $logfile


if [ groupe=10000 ] || [ groupe=10001 ] || [ groupe=10002 ]; then
	#controle de la présence du fichier liste_pc.csv dans icones qui sert de référence 
	echo "controle presence liste_pc_esu.csv dans icones";
 	if [ -f $netlogonIcons/scripts/liste_pc_esu.csv ]; then 
		echo "La liste des pc existe" >> $logfile
		#recherche nom du pc et son groupe dans le fichier

		adresseMAC=$(cat /sys/class/net/$(ip route show default | awk '/default/ {print $5}')/address)
		nom=$(grep $adresseMAC $netlogonIcons/scripts/liste_pc_esu.csv | awk -F',' ' {gsub("\r","",$2); printf $2 } ' )
		salle=$(grep $adresseMAC $netlogonIcons/scripts/liste_pc_esu.csv | awk -F',' ' {gsub("\r","",$1); printf $3 } ' )
	
		if [ -z "$salle" ]; then
			echo "le pc n'existe pas dans la liste" >> $logfile
			salle=grp_eole
		else
			salle=$salle
			nom=$nom
		fi
	
		regname=$(cat /etc/hostname)
		if [ "$regname" = "$nom" ]; then
			echo "hostname est correctement renseigné"
		else
			echo "mise à jour de hostname"
			echo -e $nom | tee /etc/hostname >> $logfile
		fi	
	
		gm_esu=$(cat /etc/GM_ESU)

		if [ $gm_esu != $salle ]; then
			echo "$salle"
			echo "$salle" > /etc/GM_ESU

			#firefox

			gm_esu=$(cat /etc/GM_ESU)
			echo '//
lockPref("autoadmin.global_config_url", "file://$netlogonIcons/'$gm_esu'/linux/firefox.js"); '> /usr/lib/firefox/firefox.cfg
		else
			echo meme groupe on ne fait rien
		fi
		echo "MAC "$adresseMAC" / host "$nom" / salle "$salle >> $logfile
	else 
		echo "La liste des pc n'existe pas"
		#on ne tient pas compte des groupes esu par rapport au fichier
	fi
	#execution de upkg
	sudo sh /etc/esubuntu/upkg_client.sh >> $logfile
else 
	echo  "Groupe de l'utilisateur incorrect"
	echo  "Groupe de l'utilisateur incorrect" >> $logfile
	exit 0
fi

exit 0
