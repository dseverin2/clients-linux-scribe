#!/bin/bash

#### chargement de cntlm proxy authentifiant ####
# - génère le fichier  cntlm.conf dans le dossier doc du client
# - ver 2.0.1
# - 20 Mars 2018
# - CALPETARD Olivier
# a modifier les adresses ip, le domaine, les diferrents message perso
#lancement 

#On arrète le service cntlm
killall cntlm


#lecture du fichier configuration etab
. /etc/esubuntu/param_etab.conf



if [ -d "/$HOME/.gconf" ];
then 
	echo "le dossier existe";
else
	echo "le dossier n'existe pas";
fi

#controle de la présence du fichier cntlm.conf
echo "controle presense cntlm.conf";
	if [ -f /$HOME/Documents/cntlm.conf ]
	then 
	echo "Le fichier existe"
# déjà configuré on lance cntlm

	else
	echo "Impossible d'accéder aux fichiers !"
#On crée le formulaire en stockant les valeurs de sortie dans $cfgpass :/
cfgpass=`zenity --forms \
    --title="Connexion proxy $NOM_ETAB" \
    --text="$LOGNAME Entrez vos paramètres d'authentifications sur le RESEAU PEDAGOGIQUE"\
    --add-password="Entrez votre mot de passe" \
    --separator="|"`

case $? in
    0)
    
user=$LOGNAME
pass=$(cut -d \| -f1 <<< "$cfgpass")

#On génere le fichier conf pour cntlm avec le identifiant scribe
echo "Username	$LOGNAME
Domain		$DOMAINENAME
Auth		$TYPE_AUTH
Proxy		$PROXY
NoProxy		$NOPROXY
Listen		$PORTCNTLM" > /$HOME/Documents/cntlm.conf
    
#On génere le mot de passe en hasch pour fichier conf du cntlm 
echo $pass | cntlm -H -d $DOMAINENAME -u $LOGNAME >> /$HOME/Documents/cntlm.conf

sed -i "s/Password://g" /$HOME/Documents/cntlm.conf
 ;;


    1)
        echo "annulé"
	;;
    -1)
        echo "Une erreur inattendue est survenue."
	;;
esac

fi

#controle si cntlm est bon
if [ -s /$HOME/Documents/cntlm.conf ]
then
	echo " fichier non vide"
else
	echo "fichier vide -- votre session est pleine"
	zenity --error --text "Bonjour $USER, vous avez dépassé votre quota sur votre espace personnel, veuillez contacter l'administrateur réseau $AIDE"

	rm /$HOME/Documents/cntlm.conf
	exit 0

fi

#On lance cntlm 	
cntlm -c /$HOME/Documents/cntlm.conf

exit 0

  
