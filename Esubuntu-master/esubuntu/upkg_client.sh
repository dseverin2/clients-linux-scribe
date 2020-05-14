#!/bin/bash

#### chargement d'une tache en root pour installer une application a l'ouverture de session ubuntu ####
# - récupère le script script_install.sh et execute si et seulement si il n'a pas déja été fait
# - ver 1.0.1
# - 31 mars 2015
# - CALPETARD Olivier


#les fichier se trouve dans icones$
#lancement de upkg client seulement si le compte utilisateur utilise une session scribe
gm_esu=grp_eole
#lecture du groupe ESU
if [ -f "/etc/GM_ESU" ];then
echo "Le PC est dans le groupe esu"
gm_esu=$(cat /etc/GM_ESU)
fi

#lecture du fichier upkg.txt sur le serveur pour commande install apps $pkglist
cat /tmp/netlogon/icones/$gm_esu/linux/upkg/upkg.txt >/dev/null 2>&1; pkglist=$? 


if [ $pkglist -eq 1 ]
	then 
	#si le contenue de upkg.txt égale a 0 alors on quitte 
		exit 0
		#controle de la présence du fichier stamp.date qui sert de référence 
		echo "controle presense stamp";
		elif [ -f /usr/local/upkg_client/stamp.date ]
		then 
		echo "Le fichier existe"
		#comparaison de stamp.date 
		cmp /usr/local/upkg_client/stamp.date /tmp/netlogon/icones/$gm_esu/linux/upkg/stamp.date 1>/dev/null 2>&1; resultat=$?
		if [ $resultat -eq 0 ]; then   #cmp retourne 0 si identiques
			echo "Identiques !"
			#stamp.date est identique on attribut la valeur non upkg pour ne pas installer
			stamp=nupkg
			echo $stamp
		elif [ $resultat -eq 1 ]; then    #cmp retourne 1 si NON identiques
		echo "Non Identiques !"
		#stamp.date est différent on attribut la valeur upkg pour une installe
		stamp=upkg
		echo $stamp
		else		echo "Impossible d'accéder aux fichiers !"
		fi
	
		else 
		echo "Le fichier existe pas"
		#stamp.date n'existe pas on attribut la valeur upkg pour une installe
		stamp=upkg
		echo $stamp
		echo $pkglist
fi
	
#si le contenue de upkg.txt égale a script_install.sh et stamp égale a upgk alors on lance le script
if [ $stamp = "upkg" ]
		then
		echo "install script"
		#copie de script_install.sh vers /usr/local/upkg_client/
		cp /tmp/netlogon/icones/$gm_esu/linux/upkg/script_install.sh /usr/local/upkg_client/ 
		#on le rend executable
		chmod +x /usr/local/upkg_client/script_install.sh
		/usr/local/upkg_client/script_install.sh
		echo "mise a jour stamp"
		#copie de stamp.date du serveur vers /usr/local/upkg_client/ pour mise a jours
		cp /tmp/netlogon/icones/$gm_esu/linux/upkg/stamp.date /usr/local/upkg_client/ 
		#stamp est égale a nupkg on quitte
		else 
		echo "on sort"
fi

exit 0

  
