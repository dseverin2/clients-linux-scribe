#!/bin/bash

# Liste des fonctions utilisées :
# addtoend Ajoute les lignes données en paramètres à la fin du fichier donné en 1er paramètre si elles ne sont pas déjà présentes.
# initlog Initialise le fichier de log avec la date du jour
# writelog Ecrit les éléments donnés en paramètres à la suite du fichier de log (Si le 1er argument est INITBLOC, insère ******* au préalable. Si le 1er argument est ENDBLOC, insère ******)
# getversion Récupère la version d'ubuntu utilisée et interrompt le script si elle n'est pas compatible


if [ -e ./config.cfg ]; then
  my_dir="$(dirname "$0")"
  source $my_dir/config.cfg
else
  echo "Fichier config.cfg absent ! Interruption de l'installation."
  exit
fi

# Test Mise à jour
function majIntegrdom {
	wget --no-check-certificate -O /tmp/_VERSION https://raw.githubusercontent.com/dseverin2/clients-linux-scribe/master/_VERSION
	source /tmp/_VERSION
	onlineVersion=$versionscript
	if [ -e ./_VERSION ]; then
		source $my_dir/_VERSION
		offlineVersion=$versionscript
	else
		offlineVersion=""
		echo "Fichier _VERSION absent !"
	fi
	if [ "$offlineVersion" != "$onlineVersion" ]; then
		echo "La version en ligne et celle présente sur ce PC sont différentes. Voulez-vous mettre à jour ? o/[N]"
		read autorisationMaj
		if [ "$autorisationMaj" == "o" ] || [ "$autorisationMaj" == "O" ]; then
			echo "Mise à jour du script..."
			wget --no-check-certificate https://github.com/dseverin2/clients-linux-scribe/archive/master.zip
			unzip master.zip
			cp -fr clients-linux-scribe-master/* .
			rm -fr clients-linux-scribe-master/ master.zip
			chmod +x *.sh
			echo "Scripts mis à jour veuillez relancer sudo ./ubuntu-et-variantes-integrdom.sh"
			exit
		else
			echo "Aucune modification apportée aux scripts présents"
		fi
	fi
}


# Initialisation du fichier de log (situé sur le bureau de l'admin local)
function initlog {
	if [ -e $logfile ]; then
		rm -fr $logfile
	fi
	echo `date` > $logfile
}

# Ecriture des paramètres dans le fichier de log
function writelog {
	nbParams=$#
	dernierParam=${!nbParams} 
	
	if [ "$1" = "ENDBLOC" ]; then
		echo "************************ END *************************" >> $logfile
		echo "" >> $logfile
	else
		if [ "$1" = "INITBLOC" ]; then
			echo "" >> $logfile
			echo "************************ INIT *************************" >> $logfile
		fi
		for param in "$@" 
		do 
			if [ ! "$param" = "INITBLOC" ]; then
				echo -e "$param"
				echo -e "$param" >> $logfile
			fi
		done
	fi
}

# Affectation à la variable "version" suivant la variante utilisé
function getversion {	
	# Pour identifier le numéro de la version (14.04, 16.04...)
	. /etc/lsb-release
	
	version=unsupported
	if [ "$DISTRIB_RELEASE" = "14.04" ] || [ "$DISTRIB_RELEASE" = "17" ] || [ "$DISTRIB_RELEASE" = "17.3" ] ; then
	  version=trusty # Ubuntu 14.04 / Linux Mint 17/17.3
	fi

	if [ "$DISTRIB_RELEASE" = "16.04" ] || [ "$DISTRIB_RELEASE" = "18" ] || [ "$DISTRIB_RELEASE" = "18.3" ] || [ "$(echo "$DISTRIB_RELEASE" | cut -c -3)" = "0.4" ] ; then
	  version=xenial # Ubuntu 16.04 / Linux Mint 18/18.3 / Elementary OS 0.4.x
	fi

	if [ "$DISTRIB_RELEASE" = "18.04" ] || [ "$DISTRIB_RELEASE" = "19" ] || [ "$DISTRIB_RELEASE" = "5.0" ] ; then 
	  version=bionic # Ubuntu 18.04 / Mint 19 / Elementary OS 5.0
	fi

	if [ "$DISTRIB_RELEASE" = "20.04" ] || [ "$DISTRIB_RELEASE" = "20" ] || [ "$DISTRIB_RELEASE" = "6.0" ] ; then 
	  version=focal # Ubuntu 20.04 / Mint 20 / Elementary OS 6.0
	fi
	
	if [ "$version" == "unsupported" ]; then
	  echo "Désolé, vous n'êtes pas sur une version compatible !"
	  exit
	fi
}

# Ecriture du 1er paramètre à la suite du fichier indiqué par le 2e argument
function addtoend {
	for param in "$@" 
	do
		if [ "$1" = "$param" ]; then
			destfile=$param
		else
			grep "$param" $destfile > /dev/null
			if [ $? != 0 ]; then
				echo "$param" >> $destfile
			fi
		fi
	done
}
