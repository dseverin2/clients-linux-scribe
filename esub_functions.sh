#!/bin/bash

# Liste des fonctions utilisées :
# initlog Initialise le fichier de log avec la date du jour
# writelog Ecrit les éléments donnés en paramètres à la suite du fichier de log
# getversion Récupère la version d'ubuntu utilisée et interrompt le script si elle n'est pas compatible


if [ -e ./config.cfg ]; then
  my_dir="$(dirname "$0")"
  source $my_dir/config.cfg
else
  echo "Fichier config.cfg absent ! Interruption de l'installation."
  exit
fi

# Initialisation du fichier de log (situé sur le bureau de l'admin local)
function initlog {
	if [ -e $logfile ]; then
		rm -fr $logfile
	fi
	echo `date` > $logfile
}

# Ecriture des paramètres dans le fichier de log
function writelog {
	for param in "$@" 
	do 
		echo -e "$param"
		echo -e "$param" >> $logfile
	done
}

# Affectation à la variable "version" suivant la variante utilisé
function getversion {
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
