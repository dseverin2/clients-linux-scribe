#!/bin/bash

#### regénère le fichier cntlm.conf pour cntlm proxy authentifiant ####
# - regénère le fichier  cntlm.conf dans le dossier doc du client
# - ver 2.0.1
# - 20 mars 2018
# - CALPETARD Olivier
# a modifier les adresses ip, le domaine, les diferrents message perso
#lancement 
killall cntlm


#lecture du fichier configuration etab
. /etc/esubuntu/param_etab.conf


#On crée le formulaire en stockant les valeurs de sortie dans $cfgpass :/
cfgpass=`zenity --forms \
    --title="Connexion proxy $NOM_ETAB" \
	--text="$LOGNAME Entre ton mot de passe réseau pour te connecter à internet"\
    --add-password="mot de passe réseau pédagogique" \
    --separator="|"`

case $? in
    0)
    
user=$LOGNAME
pass=$(cut -d \| -f1 <<< "$cfgpass")

echo "Username	$LOGNAME
Domain		$DOMAINENAME
Auth		$TYPE_AUTH
Proxy		$PROXY
NoProxy		$NOPROXY
Listen		$PORTCNTLM" > /$HOME/Documents/cntlm.conf
    

echo $user
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


cntlm -c /$HOME/Documents/cntlm.conf







