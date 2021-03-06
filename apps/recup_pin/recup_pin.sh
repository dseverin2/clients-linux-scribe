#!/bin/bash
# Script de Didier SEVERIN (23/08/20)
# Version 3.3

# Ce script compile un driver contenant le code pin de l'utilisateur courant (s'il en a un défini dans le fichier csv)
# Pour ce faire il copie le driver original en remplaçant les lignes de définition des codes pin par défaut
# On va remplacer *DefaultKmManagement: Default par *DefaultKmManagement: xxxxxx
# Ainsi que toutes les lignes de définition des codes pin par une seule ligne
# *KmManagment xxxxxx/yyyyyy: "(zzzzzz) statusdict /setmanagementnumber get exec"
# xxxxxx est la clé identifiant le couple yyyyyy,zzzzzz
# yyyyyy désigne l'identifiant local de l'utilisateur
# zzzzzz désigne le code pin de l'utilisateur 

# Definition des fichiers locaux
basedirectory='/usr/bin/recup_pin'
baseppddirectory='/etc/cups/ppd'
pinfile=~/Documents/code_photocopieur.txt
code1="1"
code2="2"
usercode=""

# Définition des fichiers SCRIBE
driver_original=$basedirectory/DRIVER_ORIGINAL.PPD
driver_compile=$baseppddirectory/PHOTOCOPIEUSE_SDP.ppd

# Verification de l'existence du fichier contenant le code pin pour les users non élèves
if [ "$GROUPS" != "10002" ]; then
	if [ ! -e $pinfile ] ; then
		while [ $code1 != $code2 ];	do 		# S'il n'existe pas on demande le code pin avec validation
			code1=$(zenity --entry --text="Entrez votre code de photocopieuse" 2> /dev/null)
			code2=$(zenity --entry --text="Saisissez à nouveau votre code de photocopieuse" 2> /dev/null)
			if [ $code1 != $code2 ]; then
				zenity --info --text="Les codes saisis ne correspondent pas" 2> /dev/null
			fi
		done
		echo $code1 > $pinfile 				# On sauvegarde le code pin saisi dans le fichier ~/Documents/code_photocopieur.txt 
		usercode=$code1
	else
		mapfile -O 1 -t tableau < $pinfile	# Si le fichier existe, on récupère le code pin
		usercode=$(echo "${tableau[1]}")
	fi
fi

# Fonction de création du driver pour les ppd basés sur KmManagment
kmBasedDriver(){
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
}

accountBasedDriver(){
	# Comptage du nombre de ligne dans le driver original
	nombre_lignes_driver_original=$(wc -l $driver_original | awk '{print $1}')

	# Copie du début du driver original dans le driver compilé jusqu'à la ligne de définition des codes pin
	derniere_ligne_debut_driver=$(($(echo $(grep -n "*% === Constraints =============================================================" $driver_original) | cut -d ":" -f 1)-1))
	head -$derniere_ligne_debut_driver $driver_original > $driver_compile

	# Ecriture de la ligne avec le code pin correspondant à l'utilisateur
	echo '*% **** Account number
*JCLOpenUI *JCLMXaccount/numero: PickOne
*OrderDependency: 80 JCLSetup *JCLMXaccount' >> $driver_compile
	insert_line='*DefaultJCLMXaccount: A'$usercode
	echo $insert_line >> $driver_compile
	insert_line2='*JCLMXaccount A'$usercode'/'$usercode': "@PJL SET ACCOUNTNUMBER=<22>'$usercode'<22><0A>"'
	echo $insert_line2 >> $driver_compile
	echo "*JCLCloseUI: *JCLMXaccount" >> $driver_compile
	echo "" >> $driver_compile

	# Copie de la fin du driver original dans le driver compilé (après les lignes de définition des codes pin)
	premiere_ligne_fin_driver=$(echo $(grep -n "*% === Constraints =============================================================" $driver_original) | cut -d ":" -f 1)
	nombre_lignes_avant_fin=$(($nombre_lignes_driver_original-$premiere_ligne_fin_driver+1))
	tail -$nombre_lignes_avant_fin $driver_original >> $driver_compile
}

# Compilation du driver en y insérant le code pin (si la variable usercode non vide)
if [ "$usercode" != "" ]; then 
	echo 'PIN :  '$usercode
	if grep KmManagment $driver_original; then
		kmBasedDriver
	else
		accountBasedDriver
	fi
else
	# Copie directe du driver original (pour éviter les erreurs d'absence du fichier ppd)
	cp -f $driver_original $driver_compile
fi
