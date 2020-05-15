#!/bin/bash
# Script original de Mathieu Anapotelivoua
# Modification et optimisation de Didier SEVERIN (25/03/20)
# Version 2.0

# Ce script compile un driver contenant le code pin de l'utilisateur courant (s'il en a un défini dans le fichier csv)
# Pour ce faire il copie le driver original en remplaçant les lignes de définition des codes pin par défaut
# On va remplacer *DefaultKmManagement: Default par *DefaultKmManagement: xxxxxx
# Ainsi que toutes les lignes de définition des codes pin par une seule ligne
# *KmManagment xxxxxx/yyyyyy: "(zzzzzz) statusdict /setmanagementnumber get exec"
# xxxxxx est la clé identifiant le couple yyyyyy,zzzzzz
# yyyyyy désigne l'identifiant local de l'utilisateur
# zzzzzz désigne le code pin de l'utilisateur 

# Definition du mode TEST / SCRIBE
testmode=0
if [ $testmode == 1 ]; then
	echo 'MODE : Test en Local'
	basedirectory='.'
	baseppddirectory='.'
else
	echo 'MODE : Déploiement sur Scribe'
	basedirectory='/usr/bin/recup_pin'
	baseppddirectory='/etc/cups/ppd'
fi

# Identité par défaut
defaultcode="0000"
usercode=$defaultcode
defaultuser="null"
founduser=$defaultuser

# Définition des fichiers SCRIBE
pin_list_csv=$basedirectory/id_prof_photocop.csv
driver_original=$basedirectory/DRIVER_ORIGINAL.PPD
driver_compile=$baseppddirectory/PHOTOCOPIEUSE_SDP.ppd

echo 'USER : '$USER
# Parsing des lignes du fichier csv
while IFS=',' read nom prenom login pin trash; do 	# Si l'utilisateur a un code pin photocopieuse...
	if [ $USER = $login ] ; then					# On stocke le code pin correspondant dans usercode
		usercode=$pin
		founduser=$login 
		break
	fi
done < $pin_list_csv

# Compilation du driver en y insérant le code pin (si
if [ $founduser != $defaultuser ]; then 
	echo 'PIN :  '$usercode

	# Comptage du nombre de ligne dans le driver original
	nombre_lignes_driver_original=$(wc -l $driver_original | awk '{print $1}')

	# Copie du début du driver original dans le driver compilé jusqu'à la ligne de définition des codes pin
	derniere_ligne_debut_driver=$(($(echo $(grep -n "*DefaultKmManagment: Default" $driver_original) | cut -d ":" -f 1)-1))
	head -$derniere_ligne_debut_driver $driver_original > $driver_compile

	# Ecriture de la ligne avec le code pin correspondant à l'utilisateur
	echo '*DefaultKmManagment: MG'$usercode'
	*KmManagment Default/Inactif: ""' >> $driver_compile
	insert_line='*KmManagment MG'$usercode'/'$usercode': "('$usercode') statusdict /setmanagementnumber get exec"'
	echo $insert_line$insert_line2 >> $driver_compile

	# Copie de la fin du driver original dans le driver compilé (après les lignes de définition des codes pin)
	premiere_ligne_fin_driver=$(echo $(grep -n "*?KmManagment:" $driver_original) | cut -d ":" -f 1)
	nombre_lignes_avant_fin=$(($nombre_lignes_driver_original-$premiere_ligne_fin_driver+1))
	tail -$nombre_lignes_avant_fin $driver_original >> $driver_compile
else
	# Copie directe du driver original (pour éviter les erreurs d'absence du fichier ppd)
	cp -f $driver_original $driver_compile
fi
