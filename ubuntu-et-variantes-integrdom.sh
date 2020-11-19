#!/bin/bash
# version 2.5.2
# Dernières modifications :
# - 19/11/2020 (Modification de l'ordre des installations)
# - 21/09/2020 (Ajout python à l'install)
# - 07/09/2020 (Correction d'un bug lié au wallpapers) 
# - 30/06/2020 (Paramétrage auth-client-config)
# - 10/10/2020 (Lecture DVD dans le fichier config)


# Testé & validé pour les distributions suivantes :
################################################
# - Ubuntu 14.04 & 16.04 (Unity) & 18.04 (Gnome Shell)
# - Xubuntu 14.04, 16.04 et 18.04 (Xfce)
# - Lubuntu 14.04 & 16.04 (Lxde) et 18.04 (Lxde/LxQt)
# - Ubuntu Mate 16.04 & 18.04 (Mate)
# - Ubuntu Budgie 18.04 (Budgie)
# - Elementary OS 0.4 (Pantheon)
# - Linux Mint 17.X & 18.X (Cinnamon/Mate/Xfce)

# Si vous activez "Esubuntu", la fonction de déport distant des wallpapers ne fonctionnera que sur Ubuntu/Unity 14.04/16.04 (pas les variantes)
# Pour Esubuntu, pack à uploader dans /netlogon/icones/{votre groupe esu} : https://github.com/dane-lyon/experimentation/raw/master/config_default.zip
# Esubuntu fonctionne sous Ubuntu Mate 18.04 pour le déploiement d'application/script

###### Intégration pour un Scribe 2.3, 2.4, 2.5 et 2.6 avec les clients basés sur Trusty et Xenial ###### 

#######################################################
# Rappel des problèmes connus
#######################################################

### Si vous avez un Scribe en version supérieure à 2.3, pour avoir les partages vous avez ceci à faire :
# https://dane.ac-lyon.fr/spip/Client-Linux-activer-les-partages

### Si vous utilisez Oscar pour le déploiement de poste, à partir de la 16.04LTS, ce n'est compatible qu'avec les versions 
#récentes d'Oscar mais pas les anciennes versions.

# --------------------------------------------------------------------------------------------------------------------

### Changelog depuis version originale (pour 12.04/14.04 à l'époque) :
# - paquet à installer smbfs remplacé par cifs-utils car il a changé de nom.
# - ajout groupe dialout
# - désinstallation de certains logiciels inutiles suivant les variantes
# - ajout fonction pour programmer l'extinction automatique des postes le soir
# - lecture dvd inclus
# - changement du thème MDM par défaut pour Mint (pour ne pas voir l'userlist)
# - ajout d'une ligne dans sudoers pour régler un problème avec GTK dans certains cas sur la 14.04
# - changement page d'acceuil Firefox
# - utilisation du Skel désormais compatible avec la 16.04
# - ajout variable pour contrôle de la version
# - suppression de la notification de mise à niveau (sinon par exemple en 14.04, s'affiche sur tous les comptes au démarrage)
# - prise en charge du script Esubuntu (crée par Olivier CALPETARD)
# - correction pour le montage des partages quand le noyau >= 4.13 dû au changement du protocole par défaut en SMB3
# - modification config GDM pour la version de base en 18.04 avec GnomeShell pour ne pas afficher la liste des utilisateurs
# - Ajout de raccourci pour le bureau + dossier de l'utilisateur pour les partages Perso, Documents et l'ensemble des partages.
# - Suppression icone Amazon pour Ubuntu 18.04/GS
# - Ajout de l'utilitaire "net-tools" pour la commande ifconfig
# - Condition pour ne pas activer le PPA de conky si c'est une version supérieur à 16.04 (utilisé par Esubuntu)
# - Ajout de Vim car logiciel utile de base (en alternative à nano)
# - Changement de commande d'installation : apt-get => apt
# - Applet réseau finalement non-supprimé
# - Possibilité d'enchainer automatiquement avec le script de post-install une fois le script terminé (via 1 paramètre de commande) 
# - Suppression de l'écran de démarrage d'Ubuntu avec Gnome de la 18.04
# - Mise en place d'un fichier de configuration centralisé
# - Ajout de la possibilité de paramétrer une photocopieuse à code
# - Récupération de auth-client-config pour Focal Fossa

# --------------------------------------------------------------------------------------------------------------------


## Liste des contributeurs au script :
# Christophe Deze - Rectorat de Nantes
# Cédric Frayssinet - Mission Tice Ac-lyon
# Xavier Garel - Mission Tice Ac-lyon
# Simon Bernard - Technicien Ac-Lyon
# Olivier Calpetard - Académie de la Réunion
# Didier SEVERIN - Académie de la Réunion

#############################################
# Run using sudo, of course.
#############################################
if [ "$UID" -ne "0" ]; then
	echo "Il faut etre root pour executer ce script. ==> sudo "
	exit 
fi 

# Verification de la présence des fichiers contenant les fonctions et variables communes
if [ -e ./esub_functions.sh ]; then
	source ./esub_functions.sh
	# Création du fichier de log
	initlog
	writelog "1/42-Installation de net-tools et python"
	apt install net-tools python -y
	writelog "2/42-Fichiers de configuration... OK"
else
	echo "Fichier esub_functions.sh absent ! Interruption de l'installation."
	exit
fi

### Paramétrage Proxy
if [ -e ./Param_proxy.sh ]; then
	source ./Param_proxy.sh
	writelog "3/42-Paramétrage du proxy... OK"
else
	echo "Fichier Param_proxy.sh absent ! Interruption de l'installation."
	exit
fi

# Verification de l'existence d'une mise à jour des scripts sur le git
majIntegrdom

# Vérification que le système est bien à jour et sans défaut
writelog "INITBLOC" "4/42-Mise à jour complète du système"
apt install --fix-broken -y  2>> $logfile
apt update 2>> $logfile; 
apt full-upgrade -y 2>> $logfile
apt install --fix-broken -y  2>> $logfile
writelog "ENDBLOC"

# Récupération de la version d'ubuntu
getversion
writelog "5/42-Version trouvée : $version... OK"

# Définition des droits sur les scripts
chmod +x $second_dir/*.sh

if $config_photocopieuse; then
	writelog "INITBLOC" "5b-Installation photocopieuse"
	$second_dir/setup_photocopieuse.sh 2>> $logfile
	writelog "ENDBLOC"
fi

########################################################################
#rendre debconf silencieux
########################################################################
export DEBIAN_FRONTEND="noninteractive" 2>> $logfile
export DEBIAN_PRIORITY="critical" 2>> $logfile

########################################################################
#suppression de l'applet switch-user pour ne pas voir les derniers connectés # Uniquement pour Ubuntu / Unity
#paramétrage d'un laucher unity par défaut : nautilus, firefox, libreoffice, calculatrice, éditeur de texte et capture d'écran
########################################################################
if [ "$(which unity)" = "/usr/bin/unity" ]; then  # si Ubuntu/Unity alors :
	writelog "3b-Suppression de l'applet switch-user et paramétrage du launcher unity par défaut"
	echo "[com.canonical.indicator.session]
user-show-menu=false
[org.gnome.desktop.lockdown]
disable-user-switching=true
disable-lock-screen=true
[com.canonical.Unity.Launcher]
favorites=[ 'nautilus-home.desktop', 'firefox.desktop','libreoffice-startcenter.desktop', 'gcalctool.desktop','gedit.desktop','gnome-screenshot.desktop' ]" > /usr/share/glib-2.0/schemas/my-defaults.gschema.override 2>> $logfile
fi

####################################################
# Téléchargement + Mise en place de Esubuntu (si activé)
####################################################
if $esubuntu; then 
	writelog "INITBLOC" "6/42-Installation d'ESUBUNTU"
	if [ ! -e ./esubuntu ]; then
		writelog "---Le répertoire esubuntu est absent. Interruption de l'installation"
		exit
	fi

	# Déplacement/extraction de l'archive + lancement par la suite
	writelog "---6a-Modification des droits et copie des fichiers de configuration"
	chmod -R +x ./esubuntu 2>> $logfile
	writelog "---6b-Lancement du script d'installation"
	./esubuntu/install_esubuntu.sh 2>> $logfile

	# Mise en place des wallpapers pour les élèves, profs, admin 
	writelog "---6c-Copie des wallpapers"
	cp -fr ./wallpaper/ /usr/share/ 2>> $logfile
	writelog "ENDBLOC"
fi

writelog "7/42-Installation de auth-client-config"
wget http://archive.ubuntu.com/ubuntu/pool/universe/a/auth-client-config/auth-client-config_0.9ubuntu1_all.deb
dpkg -i auth-client-config_0.9ubuntu1_all.deb
rm -f auth-client-config_0.9ubuntu1_all.deb

########################################################################
#Mettre la station à l'heure à partir du serveur Scribe
########################################################################
writelog "8/42-Mise à jour de la station d'heure à partir du serveur Scribe"
apt install -y ntpdate 2>> $logfile;
ntpdate $scribe_def_ip 2>> $logfile

########################################################################
#installation des paquets nécessaires
#numlockx pour le verrouillage du pavé numérique
#unattended-upgrades pour forcer les mises à jour de sécurité à se faire
########################################################################
writelog "9/42-Installation des paquets de sécurité, de montage samba et numlockx"
apt install -y ldap-auth-client libpam-mount cifs-utils nscd numlockx unattended-upgrades 2>> $logfile
	
########################################################################
# activation auto des mises à jour de sécurité
########################################################################
writelog "10/42-Activation automatique des mises à jour de sécurité"
echo "APT::Periodic::Update-Package-Lists \"1\";
APT::Periodic::Unattended-Upgrade \"1\";" > /etc/apt/apt.conf.d/20auto-upgrades 2>> $logfile

########################################################################
# Configuration du fichier pour le LDAP /etc/ldap.conf
########################################################################
writelog "11/42-Configuration du fichier pour le LDAP /etc/ldap.conf"
echo "
# /etc/ldap.conf
host $scribe_def_ip
base o=gouv, c=fr
nss_override_attribute_value shadowMax 9999" > /etc/ldap.conf 2>>$logfile

########################################################################
# activation des groupes des users du ldap
########################################################################
writelog "12/42-activation des groupes des users du ldap"
echo "Name: activate /etc/security/group.conf
Default: yes
Priority: 900
Auth-Type: Primary
Auth:
        required                        pam_group.so use_first_pass" > /usr/share/pam-configs/my_groups 2>> $logfile

########################################################################
#auth ldap
########################################################################
writelog "13/42-Définition de auth ldap"
echo "[open_ldap]
nss_passwd=passwd:  files ldap
nss_group=group: files ldap
nss_shadow=shadow: files ldap
nss_netgroup=netgroup: nis" > /etc/auth-client-config/profile.d/open_ldap 2>> $logfile

########################################################################
#application de la conf nsswitch
########################################################################
writelog "14/42-Application de la configuration nsswitch depuis auth-client-config"
apt install auth-client-config -y 2>> $logfile
auth-client-config -t nss -p open_ldap 2>> $logfile

########################################################################
#modules PAM mkhomdir pour pam-auth-update
########################################################################
writelog "15/42-modules PAM mkhomdir pour pam-auth-update"
echo "Name: Make Home directory
Default: yes
Priority: 128
Session-Type: Additional
Session:
       optional                        pam_mkhomedir.so silent" > /usr/share/pam-configs/mkhomedir 2>> $logfile

addtoend /etc/pam.d/common-auth "auth    required     pam_group.so use_first_pass" 2>> $logfile


########################################################################
# mise en place de la conf pam.d
########################################################################
writelog "16/42-Application de la configuration pam.d"
pam-auth-update consolekit ldap libpam-mount unix mkhomedir my_groups --force 2>> $logfile

########################################################################
# mise en place des groupes pour les users ldap dans /etc/security/group.conf
########################################################################
writelog "17/42-Mise en place des groupes pour les users ldap dans /etc/security/group.conf"
addtoend /etc/security/group.conf "*;*;*;Al0000-2400;floppy,audio,cdrom,video,plugdev,scanner,dialout" 2>> $logfile

########################################################################
#on remet debconf dans sa conf initiale
########################################################################
writelog "18/42-Retour de debconf dans sa configuration initiale"
export DEBIAN_FRONTEND="dialog"
export DEBIAN_PRIORITY="high"

########################################################################
#paramétrage du script de démontage du netlogon pour lightdm 
########################################################################
if [ "$(which lightdm)" = "/usr/sbin/lightdm" ]; then #Si lightDM présent
	writelog "INITBLOC" "19/42-Paramétrage du script de démontage du netlogon pour lightdm"
	touch /etc/lightdm/logonscript.sh 2>> $logfile
	addtoend /etc/lightdm/logonscript.sh "if mount | grep -q \"/tmp/netlogon\" ; then umount /tmp/netlogon ;fi" 2>> $logfile
	chmod +x /etc/lightdm/logonscript.sh 2>> $logfile

	touch /etc/lightdm/logoffscript.sh 2>> $logfile
	echo "sleep 2
umount -f /tmp/netlogon
umount -f \$HOME" > /etc/lightdm/logoffscript.sh 2>> $logfile
	chmod +x /etc/lightdm/logoffscript.sh 2>> $logfile

	########################################################################
	#paramétrage du lightdm.conf
	#activation du pavé numérique par greeter-setup-script=/usr/bin/numlockx on
	########################################################################
	writelog "---19a-Paramétrage du lightdm.conf & pavé numérique"	
	echo "[SeatDefaults]
allow-guest=false
greeter-show-manual-login=true
greeter-hide-users=true
session-setup-script=/etc/lightdm/logonscript.sh
session-cleanup-script=/etc/lightdm/logoffscript.sh
greeter-setup-script=/usr/bin/numlockx on" > /usr/share/lightdm/lightdm.conf.d/50-no-guest.conf 2>> $logfile
	writelog "ENDBLOC"
fi

# echo "GVFS_DISABLE_FUSE=1" >> /etc/environment


# Modification ancien gestionnaire de session MDM
if [ "$(which mdm)" = "/usr/sbin/mdm" ]; then # si MDM est installé (ancienne version de Mint <17.2)
	writelog "20/42-Modification de l'ancien gestionnaire de session MDM (pour Mint <17.2)"
	cp -f /etc/mdm/mdm.conf /etc/mdm/mdm_old.conf  2>> $logfile #backup du fichier de config de mdm
	wget --no-check-certificate https://raw.githubusercontent.com/dane-lyon/fichier-de-config/master/mdm.conf 2>> $logfile ; mv -f mdm.conf /etc/mdm/ 2>> $logfile ; 
fi

# Si Ubuntu Mate
if [ "$(which caja)" = "/usr/bin/caja" ]; then
	writelog "21/42-Epuration du gestionnaire de session caja (pour Ubuntu Mate)"
	apt purge -y hexchat transmission-gtk ubuntu-mate-welcome cheese pidgin rhythmbox 2>> $logfile
	snap remove ubuntu-mate-welcome 2>> $logfile
fi

# Si Lubuntu (lxde)
if [ "$(which pcmanfm)" = "/usr/bin/pcmanfm" ]; then
	writelog "22/42-Epuration du gestionnaire de session pcmanfm (pour Lubuntu LXDE)"
	apt purge -y abiword gnumeric pidgin transmission-gtk sylpheed audacious guvcview 2>> $logfile
fi

########################################################################
# Spécifique Gnome Shell
########################################################################
if [ "$(which gnome-shell)" = "/usr/bin/gnome-shell" ]; then  # si GS installé
	writelog "INITBLOC" "23/42-Paramétrage de Gnome Shell"
	# Désactiver userlist pour GDM
	echo "user-db:user
system-db:gdm
file-db:/usr/share/gdm/greeter-dconf-defaults" > /etc/dconf/profile/gdm 2>> $logfile

	writelog "---23a-Suppression de la liste des utilisateurs au login"
	mkdir /etc/dconf/db/gdm.d 2>> $logfile
	echo "[org/gnome/login-screen]
# Do not show the user list
disable-user-list=true" > /etc/dconf/db/gdm.d/00-login-screen

	writelog "---23b-Application des modifications"
	dconf update 2>> $logfile

	writelog "---23c-Suppression des icônes Amazon"
	apt purge -y ubuntu-web-launchers gnome-initial-setup 2>> $logfile

	writelog "---23d-Remplacement des snaps par défauts par la version apt (plus rapide)"
	snap remove gnome-calculator gnome-characters gnome-logs gnome-system-monitor 2>> $logfile
	apt install gnome-calculator gnome-characters gnome-logs gnome-system-monitor -y  2>> $logfile
	
	writelog "ENDBLOC"
fi


########################################################################
#Paramétrage pour remplir pam_mount.conf
########################################################################
writelog "INITBLOC" "24/42-Paramétrage pour remplir pam_mount.conf" "---/media/Serveur_Scribe"
eclairng="<volume user=\"*\" fstype=\"cifs\" server=\"$scribe_def_ip\" path=\"eclairng\" mountpoint=\"/media/Serveur_Scribe\" />"
grep "/media/Serveur_Scribe" /etc/security/pam_mount.conf.xml  >/dev/null
if [ $? != 0 ]; then
  sed -i "/<\!-- Volume definitions -->/a\ $eclairng" /etc/security/pam_mount.conf.xml 2>> $logfile
fi

writelog "---~/Documents => Perso (scribe)"
homes="<volume user=\"*\" fstype=\"cifs\" server=\"$scribe_def_ip\" path=\"perso\" mountpoint=\"~/Documents\" />"
grep "mountpoint=\"~\"" /etc/security/pam_mount.conf.xml  >/dev/null
if [ $? != 0 ]; then 
	sed -i "/<\!-- Volume definitions -->/a\ $homes" /etc/security/pam_mount.conf.xml 2>> $logfile
fi

writelog "---/tmp/netlogon (DomainAdmins)"
netlogon="<volume user=\"*\" fstype=\"cifs\" server=\"$scribe_def_ip\" path=\"netlogon\" mountpoint=\"/tmp/netlogon\"  sgrp=\"DomainUsers\" />"
grep "/tmp/netlogon" /etc/security/pam_mount.conf.xml  >/dev/null
if [ $? != 0 ]; then
  sed -i "/<\!-- Volume definitions -->/a\ $netlogon" /etc/security/pam_mount.conf.xml 2>> $logfile
fi

writelog "---Samba"
grep "<cifsmount>mount -t cifs //%(SERVER)/%(VOLUME) %(MNTPT) -o \"noexec,nosetuids,mapchars,cifsacl,serverino,nobrl,iocharset=utf8,user=%(USER),uid=%(USERUID)%(before=\\",\\" OPTIONS)\"</cifsmount>" /etc/security/pam_mount.conf.xml  >/dev/null
if [ $? != 0 ]; then
  sed -i "/<\!-- pam_mount parameters: Volume-related -->/a\ <cifsmount>mount -t cifs //%(SERVER)/%(VOLUME) %(MNTPT) -o \"noexec,nosetuids,mapchars,cifsacl,serverino,nobrl,iocharset=utf8,user=%(USER),uid=%(USERUID)%(before=\\",\\" OPTIONS),vers=1.0\"</cifsmount>" /etc/security/pam_mount.conf.xml 2>> $logfile
fi
writelog "ENDBLOC"
########################################################################
#/etc/profile
########################################################################
writelog "25/42-Inscription de fr_FR dans /etc/profile"
addtoend /etc/profile "export LC_ALL=fr_FR.utf8" "export LANG=fr_FR.utf8" "export LANGUAGE=fr_FR.utf8" 2>> $logfile

########################################################################
#ne pas créer les dossiers par défaut dans home
########################################################################
writelog "26/42-Suppression de la création des dossiers par défaut dans home"
sed -i "s/enabled=True/enabled=False/g" /etc/xdg/user-dirs.conf 2>> $logfile

########################################################################
# les profs peuvent sudo
########################################################################
writelog "27/42-Ajout des professeurs (et admin) dans la liste des sudoers"
grep "%professeurs ALL=(ALL) ALL" /etc/sudoers > /dev/null
if [ $? != 0 ]; then
  sed -i "/%admin ALL=(ALL) ALL/a\%professeurs ALL=(ALL) ALL" /etc/sudoers 2>> $logfile
  sed -i "/%admin ALL=(ALL) ALL/a\%DomainAdmins ALL=(ALL) ALL" /etc/sudoers 2>> $logfile
fi

writelog "28/42-Suppression de paquet inutile sous Ubuntu/Unity"
apt purge -y aisleriot gnome-mahjongg pidgin transmission-gtk gnome-mines gnome-sudoku blueman abiword gnumeric thunderbird 2>> $logfile;

grep "LinuxMint" /etc/lsb-release > /dev/null
if [ $? != 0 ]; then
	writelog "29/42-Suppression de MintWelcome (sous Mint)"
	apt purge -y mintwelcome 2>> $logfile;
fi

writelog "30/42-Suppression de l'envoi des rapport d'erreurs"
echo "enabled=0" > /etc/default/rapport 2>> $logfile

#writelog "suppression de l'applet network-manager"
#mv /etc/xdg/autostart/nm-applet.desktop /etc/xdg/autostart/nm-applet.old

writelog "31/42-suppression du menu messages"
apt purge -y indicator-messages  2>> $logfile

writelog "32/42-Changement page d'accueil firefox"
addtoend /usr/lib/firefox/defaults/pref/channel-prefs.js "$pagedemarragepardefaut"  2>> $logfile

writelog "33/42-Installation de logiciels basiques"
apt install -y vim htop 2>> $logfile

writelog "34/42-Gestion lecture de DVD"
# Lecture DVD sur Ubuntu 16.04 et supérieur ## répondre oui aux question posés...
if $lectureDVD; then
	apt install -y libdvd-pkg ; dpkg-reconfigure libdvd-pkg
fi

# Lecture DVD sur Ubuntu 14.04
if [ "$version" = "trusty" ]; then
	apt install -y libdvdread4 && bash /usr/share/doc/libdvdread4/install-css.sh 2>> $logfile
fi

# Résolution problème dans certains cas uniquement pour Trusty (exemple pour lancer gedit directement avec : sudo gedit)
if [ "$version" = "trusty" ]; then
	addtoend /etc/sudoers 'Defaults        env_keep += "DISPLAY XAUTHORITY"' 2>> $logfile
fi

# Spécifique base 16.04 ou 18.04 : pour le fonctionnement du dossier /etc/skel 
if [ "$version" = "xenial" ] || [ "$version" = "bionic" ]  || [ "$version" = "focal" ]; then
	sed -i "30i\session optional        pam_mkhomedir.so" /etc/pam.d/common-session 2>> $logfile
fi

if [ "$version" = "bionic" ] || [ "$version" = "focal" ]; then
	writelog "35/42-Création de raccourcis sur le bureau + dans dossier utilisateur (commun+perso+lespartages)"
	if [ ! -e skel.tar.gz ]; then
		wget http://nux87.free.fr/pour_script_integrdom/skel.tar.gz
	fi
	tar -xzf skel.tar.gz -C /etc/ 2>> $logfile
	rm -f skel.tar.gz 2>> $logfile
fi

# Suppression de notification de mise à niveau
writelog "36/42-Suppression de notification de mise à niveau" 
sed -r -i 's/Prompt=lts/Prompt=never/g' /etc/update-manager/release-upgrades 2>> $logfile

# Enchainer sur un script de Postinstallation
if $postinstallbase; then 
	writelog "INITBLOC" "37/42-PostInstallation basique"
	mv ./$second_dir/ubuntu-et-variantes-postinstall.sh . 2>> $logfile
	chmod +x ubuntu-et-variantes-postinstall.sh 2>> $logfile ; ./ubuntu-et-variantes-postinstall.sh 2>> $logfile ; rm -f ubuntu-et-variantes-postinstall.sh 2>> $logfile ;
	writelog "ENDBLOC"
fi

writelog "38/42-Installation du gestionnaire de raccourcis"
apt-get install xbindkeys xbindkeys-config -y 2>> $logfile

writelog "39/42-Gestion des partitions exfat"
apt-get install -y exfat-utils exfat-fuse 2>> $logfile

if $postinstalladditionnel; then 
	if [ "$version" = "bionic" ] || [ "$version" = "focal" ]; then
		writelog "INITBLOC" "40/42-PostInstallation avancée"
		sudo -u "$SUDO_USER" wget --no-check-certificate https://github.com/simbd/Ubuntu_20.04LTS_PostInstall/archive/master.zip 2>> $logfile
		sudo -u "$SUDO_USER" unzip -o master.zip -d . 2>> $logfile
		sudo -u "$SUDO_USER" chmod +x Ubuntu_20.04LTS_PostInstall-master/*.sh  2>> $logfile
		sudo -u "$SUDO_USER" ./Ubuntu_20.04LTS_PostInstall-master/Postinstall_Ubuntu-20.04LTS_FocalFossa.sh 2>> $logfile
		sudo -u "$SUDO_USER" rm -fr master.zip Ubuntu_20.04LTS_PostInstall-master 2>> $logfile;
		writelog "ENDBLOC"
	fi
fi

writelog "41/42-Nettoyage de la station avant clonage"
apt-get -y autoremove --purge 2>> $logfile ; apt-get -y clean 2>> $logfile
clear


###################################################
# cron d'extinction automatique à lancer ?
###################################################
if [ "$extinction" != "" ]; then
	writelog "42/42-Paramétrage de l'extinction automatique à $extinction h"
	echo "0 $extinction * * * root /sbin/shutdown -h now" > /etc/cron.d/prog_extinction  2>> $logfile
fi

writelog "FIN de l'integration"
if $reboot; then
	reboot
else
	echo "Pensez à redémarrer avant toute nouvelle opération sensible"
fi
