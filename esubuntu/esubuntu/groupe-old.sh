#!/bin/bash

#### utilitaire pour upkg ####
# - récupère la valeur du groupe et execute upkg_client si 
# - ver 2.1
# - 28 mai 2020
# - CALPETARD Olivier
# - SEVERIN Didier (ajout d'inscription dans un log)

logfile="/tmp/esubupkg.log"

echo `date` > $logfile
groupe=$GROUPS
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
	echo "Launching /etc/esubuntu/upkg_client.sh" >> $logfile
	sudo sh /etc/esubuntu/upkg_client.sh
else 
	echo  "Aborting" >> $logfile
	exit 0
fi

#exit 0
