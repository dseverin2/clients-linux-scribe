#!/bin/bash

#### changement de fond ecran ouverture de session ubuntu ####
# - récupère la valeur du groupe et attribut en fonction les fond ecran génére par esu
# - gestion des restriction gsetting
# - ver 2.2
# - 22 février 2021
# - CALPETARD Olivier
# - SEVERIN Didier (ajout d'inscription dans un log & refresh des icones)

logfile="/tmp/esubbackground.log"

sudo rm -f $logfile
echo `date` > $logfile
#groupe=$GROUPS

#les fichiers se trouvent dans icones$ 
#lecture du groupe ESU
gm_esu=grp_eole

if [ -f "/etc/GM_ESU" ];then
	echo "Le PC est dans le groupe esu"
	gm_esu=$(cat /etc/GM_ESU)
fi

echo "Le PC est dans le groupe esu $gm_esu" >> $logfile

sleep 3

#lecture parametres utilisateur

case $GROUPS in
10000)
	variable=Admin
	rm -f /$HOME/Desktop/*.desktop
	cp /tmp/netlogon/icones/$gm_esu/_Machine/Bureau/*.desktop  /$HOME/Desktop/
	cp /tmp/netlogon/icones/$gm_esu/DomainAdmins/Bureau/*.desktop  /$HOME/Desktop/
	#cp /tmp/netlogon/icones/$gm_esu/administratifs/Bureau/*.desktop  /$HOME/Desktop/
	chmod +x /$HOME/Desktop/*.desktop
	;;
10001)
	variable=Prof
	rm -f /$HOME/Desktop/*.desktop
	cp /tmp/netlogon/icones/$gm_esu/_Machine/Bureau/*.desktop  /$HOME/Desktop/
	cp /tmp/netlogon/icones/$gm_esu/professeurs/Bureau/*.desktop  /$HOME/Desktop/
	chmod +x /$HOME/Desktop/*.desktop
	;;
10002)
	variable=Eleve
	rm -f /$HOME/Desktop/*.desktop
	cp /tmp/netlogon/icones/$gm_esu/_Machine/Bureau/*.desktop  /$HOME/Desktop/
	cp /tmp/netlogon/icones/$gm_esu/eleves/Bureau/*.desktop  /$HOME/Desktop/
	chmod +x /$HOME/Desktop/*.desktop
	;;
*)
	variable=undefined
	echo "Groupe trouvé : $variable" >> $logfile
	gsettings set org.gnome.desktop.background picture-uri "file:///home/$USER/Images/images.jpg"
	exit 0
	;;
esac
echo "Groupe trouvé : $variable" >> $logfile

wallpaper=$(cat /tmp/netlogon/icones/$gm_esu/$variable.txt)
echo "Wallpaper : $wallpaper" >> $logfile

#pour ubuntu mate
if [ "$XDG_CURRENT_DESKTOP" = "MATE" ] ; then
	gsettings set org.mate.background picture-filename "$wallpaper"
else
	gsettings set org.gnome.desktop.background picture-uri "file:///"$wallpaper""
fi

echo "Lancement de conky avec lecture du fichier de conf :" >> $logfile
cat /tmp/netlogon/icones/posteslinux/conky/conky.cfg >> $logfile
conky -c /tmp/netlogon/icones/posteslinux/conky/conky.cfg

echo "Lancement du gpo lecture fichier gset du groupe esu :" >> $logfile
cp /tmp/netlogon/icones/$gm_esu/linux/gset/gset.sh /tmp
chmod +x /tmp/gset.sh
/tmp/gset.sh
rm /tmp/gset.sh
echo "Fin" >> $logfile
exit 0
