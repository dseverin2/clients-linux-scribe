#!/bin/bash

#### utilitaire pour upkg ####
# - récupère la valeur du groupe et execute upkg_client si 
# - ver 2.0.1
# - 20 mars 2018
# - CALPETARD Olivier



#administratif = 10000
#prof = 10001
#eleve = 10002
groupe=$GROUPS


if [ groupe=10000 ] || [ groupe=10001 ] || [ groupe=10002 ]
then
echo "ok"
 sudo sh /etc/esubuntu/upkg_client.sh
else 
echo  "pas ok"
	exit 0
fi

#exit 0
