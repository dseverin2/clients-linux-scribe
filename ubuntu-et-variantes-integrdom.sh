#!/bin/bash
# version 2.4.0
# Dernière modification : 02/06/2020 (Spécification LinuxMint pour mintwelcome & Récupération auth-client-config pour Focal)


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
if [ "$UID" -ne "0" ]
then
  echo "Il faut etre root pour executer ce script. ==> sudo "
  exit 
fi 

# Verification de la présence des fichiers contenant les fonctions et variables communes
if [ -e ./esub_functions.sh ]; then
  my_dir="$(dirname "$0")"
  source $my_dir/esub_functions.sh
else
  echo "Fichier esub_functions.sh absent ! Interruption de l'installation."
  exit
fi

# Récupération de la version d'ubuntu
getversion

# Création du fichier de log
initlog
writelog "1-Fichiers de configuration... OK\nVersion trouvée : $version... OK"

# Définition des droits sur les scripts
chmod +x $second_dir/*.sh

if [ $config_photocopieuse = "yes" ]; then
	writelog "INITBLOC" "1b-Installation photocopieuse"
	$second_dir/setup_photocopieuse.sh 2>> $logfile
	writelog "ENDBLOC"
fi

# Réparation des éventuelles erreurs de paquets post first install
writelog "2-Réparation des éventuelles erreurs de paquets post first install"
apt --fix-broken install -y  2>> $logfile

#############################################
# Modification du /etc/wgetrc.
#############################################
writelog "3-Paramétrage du proxy dans /etc/wgetrc"
addtoend /etc/wgetrc "" "https_proxy = $proxy_wgetrc" "http_proxy = $proxy_wgetrc" "ftp_proxy = $proxy_wgetrc" "use_proxy=on" "proxy-user = $scribeuserapt" "proxy-password = $scribepass"  2>> $logfile

###################################################
# cron d'extinction automatique à lancer ?
###################################################
if [ "$extinction" != "" ]; then
	writelog "3a-Paramétrage de l'extinction automatique à $extinction h"
	echo "0 $extinction * * * root /sbin/shutdown -h now" > /etc/cron.d/prog_extinction  2>> $logfile
fi

########################################################################
#rendre debconf silencieux
########################################################################
export DEBIAN_FRONTEND="noninteractive"
export DEBIAN_PRIORITY="critical"

########################################################################
#suppression de l'applet switch-user pour ne pas voir les derniers connectés # Uniquement pour Ubuntu / Unity
#paramétrage d'un laucher unity par défaut : nautilus, firefox, libreoffice, calculatrice, éditeur de texte et capture d'écran
########################################################################
if [ "$(which unity)" = "/usr/bin/unity" ] ; then  # si Ubuntu/Unity alors :
	writelog "3b-Suppression de l'applet switch-user et paramétrage du launcher unity par défaut"
	echo "[com.canonical.indicator.session]
user-show-menu=false
[org.gnome.desktop.lockdown]
disable-user-switching=true
disable-lock-screen=true
[com.canonical.Unity.Launcher]
favorites=[ 'nautilus-home.desktop', 'firefox.desktop','libreoffice-startcenter.desktop', 'gcalctool.desktop','gedit.desktop','gnome-screenshot.desktop' ]
" > /usr/share/glib-2.0/schemas/my-defaults.gschema.override
fi

#######################################################
#Paramétrage des paramètres Proxy pour tout le système
#######################################################
if [[ "$proxy_def_ip" != "" ]] || [[ $proxy_def_port != "" ]] ; then
	writelog "INITBLOC" "Paramétrage du proxy $proxy_def_ip:$proxy_def_port" 
	
	#Paramétrage des paramètres Proxy pour Gnome
	#######################################################
	writelog "---Inscription du proxy dans le schéma de gnome"
	grep "ignore-hosts=$proxy_gnome_noproxy" /usr/share/glib-2.0/schemas/my-defaults.gschema.override > /dev/null
	if [ $? != 0 ]; then
	  echo "[org.gnome.system.proxy]
mode='manual'
use-same-proxy=true
ignore-hosts=$proxy_gnome_noproxy
[org.gnome.system.proxy.http]
host='$proxy_def_ip'
port=$proxy_def_port
[org.gnome.system.proxy.https]
host='$proxy_def_ip'
port=$proxy_def_port
	" >> /usr/share/glib-2.0/schemas/my-defaults.gschema.override
	fi

	  glib-compile-schemas /usr/share/glib-2.0/schemas 2>> $logfile

	#Paramétrage du Proxy pour le système
	######################################################################
	writelog "---Inscription du proxy dans /etc/environment"
	addtoend /etc/environment "http_proxy=http://$proxy_def_ip:$proxy_def_port/" "https_proxy=http://$proxy_def_ip:$proxy_def_port/" "ftp_proxy=http://$proxy_def_ip:$proxy_def_port/" "no_proxy=\"$proxy_env_noproxy\"" 2>> $logfile

	#Paramétrage du Proxy pour apt
	######################################################################
	writelog "---Inscription du proxy pour apt"
	echo "Acquire::http::proxy \"http://$proxy_def_ip:$proxy_def_port/\";
	Acquire::ftp::proxy \"ftp://$proxy_def_ip:$proxy_def_port/\";
	Acquire::https::proxy \"https://$proxy_def_ip:$proxy_def_port/\";" > /etc/apt/apt.conf.d/20proxy

	#Permettre d'utiliser la commande add-apt-repository derrière un Proxy
	######################################################################
	writelog "---Autorisation de ma commande add-apt-repository derrière un proxy"
	addtoend /etc/sudoers "Defaults env_keep = https_proxy" 2>> $logfile
fi

# Modification pour ne pas avoir de problème lors du rafraichissement des dépots avec un proxy
# cette ligne peut être commentée/ignorée si vous n'utilisez pas de proxy ou avec la 14.04.
writelog "---Patch de /etc/apt/apt.conf pour empêcher les erreurs de rafraichissement des dépots"
addtoend /etc/apt/apt.conf "Acquire::http::No-Cache true;" "Acquire::http::Pipeline-Depth 0;" 2>> $logfile

writelog "ENDBLOC"

# Vérification que le système est bien à jour
writelog "INITBLOC" "Mise à jour complète du système"
apt update 2>> $logfile; apt full-upgrade -y 2>> $logfile
writelog "ENDBLOC"

# Ajout de Net-tools pour ifconfig en 18.04 et futures versions
writelog "Installation de Net-tools pour ifconfig (et autres)"
apt install -y net-tools 2>> $logfile

####################################################
# Téléchargement + Mise en place de Esubuntu (si activé)
####################################################
if [ "$esubuntu" = "yes" ] ; then 
	writelog "INITBLOC" "Installation d'ESUBUNTU"
	# Téléchargement des paquets
	wget --no-check-certificate https://github.com/dseverin2/esubuntu/archive/master.zip 2>> $logfile
	if [ -e master.zip ]; then
		writelog "---Esubuntu-master récupéré sur github"
		unzip master.zip
		rm -fr master.zip
	else
		writelog "---Esubuntu-master n'a pas pu être récupéré. Interruption de l'installation"
		exit
	fi

	# Déplacement/extraction de l'archive + lancement par la suite
	writelog "---Modification des droits et copie des fichiers de configuration"
	chmod -R +x ./esubuntu-master 2>> $logfile
	cp config.cfg esub_functions.sh ./esubuntu-master/ 2>> $logfile
	writelog "---Lancement du script d'installation"
	./esubuntu-master/install_esubuntu.sh 2>> $logfile

	# Mise en place des wallpapers pour les élèves, profs, admin 
	writelog "Copie des wallpapers"
	if [ -e /usr/share/wallpaper ]; then
		rm -fr /usr/share/wallpaper 2>> $logfile
	fi
	mv -f ./wallpaper /usr/share/ 2>> $logfile
	writelog "ENDBLOC"
fi

########################################################################
#Mettre la station à l'heure à partir du serveur Scribe
########################################################################
writelog "Mise à jour de la station d'heure à partir du serveur Scribe"
apt install -y ntpdate 2>> $logfile;
ntpdate $scribe_def_ip 2>> $logfile

########################################################################
#installation des paquets nécessaires
#numlockx pour le verrouillage du pavé numérique
#unattended-upgrades pour forcer les mises à jour de sécurité à se faire
########################################################################
writelog "Installation des paquets de sécurité, de montage samba et numlockx"
apt install -y ldap-auth-client libpam-mount cifs-utils nscd numlockx unattended-upgrades 2>> $logfile
	
########################################################################
# activation auto des mises à jour de sécurité
########################################################################
writelog "Activation automatique des mises à jour de sécurité"
echo "APT::Periodic::Update-Package-Lists \"1\";
APT::Periodic::Unattended-Upgrade \"1\";" > /etc/apt/apt.conf.d/20auto-upgrades

########################################################################
# Configuration du fichier pour le LDAP /etc/ldap.conf
########################################################################
writelog "Configuration du fichier pour le LDAP /etc/ldap.conf"
echo "
# /etc/ldap.conf
host $scribe_def_ip
base o=gouv, c=fr
nss_override_attribute_value shadowMax 9999
" > /etc/ldap.conf

########################################################################
# activation des groupes des users du ldap
########################################################################
writelog "activation des groupes des users du ldap"
echo "Name: activate /etc/security/group.conf
Default: yes
Priority: 900
Auth-Type: Primary
Auth:
        required                        pam_group.so use_first_pass" > /usr/share/pam-configs/my_groups

########################################################################
#auth ldap
########################################################################
writelog "auth ldap"
echo "[open_ldap]
nss_passwd=passwd:  files ldap
nss_group=group: files ldap
nss_shadow=shadow: files ldap
nss_netgroup=netgroup: nis
" > /etc/auth-client-config/profile.d/open_ldap

########################################################################
#application de la conf nsswitch
########################################################################
authclientconfigprefix=""
if [ "$version" = "focal" ]; then
	writelog "Récupération et installation de auth-client-config"
	wget --no-check-certificate http://archive.ubuntu.com/ubuntu/pool/universe/a/auth-client-config/auth-client-config_0.9ubuntu1.tar.gz 2>> $logfile
	unzip auth-client-config_0.9ubuntu1.tar.gz
	authclientconfigprefix="./auth-client-config_0.9ubuntu1/"
fi
writelog "Application de la configuration nsswitch depuis $authclientconfigprefix auth-client-config"
"$authclientconfigprefix"auth-client-config -t nss -p open_ldap 2>> $logfile

########################################################################
#modules PAM mkhomdir pour pam-auth-update
########################################################################
writelog "modules PAM mkhomdir pour pam-auth-update"
echo "Name: Make Home directory
Default: yes
Priority: 128
Session-Type: Additional
Session:
       optional                        pam_mkhomedir.so silent" > /usr/share/pam-configs/mkhomedir


addtoend /etc/pam.d/common-auth "auth    required     pam_group.so use_first_pass" 2>> $logfile


########################################################################
# mise en place de la conf pam.d
########################################################################
writelog "Application de la configuration pam.d"
pam-auth-update consolekit ldap libpam-mount unix mkhomedir my_groups --force 2>> $logfile

########################################################################
# mise en place des groupes pour les users ldap dans /etc/security/group.conf
########################################################################
writelog "Mise en place des groupes pour les users ldap dans /etc/security/group.conf"
addtoend /etc/security/group.conf "*;*;*;Al0000-2400;floppy,audio,cdrom,video,plugdev,scanner,dialout" 2>> $logfile

########################################################################
#on remet debconf dans sa conf initiale
########################################################################
writelog "Retour de debconf dans sa configuration initiale"
export DEBIAN_FRONTEND="dialog"
export DEBIAN_PRIORITY="high"

########################################################################
#paramétrage du script de démontage du netlogon pour lightdm 
########################################################################
if [ "$(which lightdm)" = "/usr/sbin/lightdm" ] ; then #Si lightDM présent
	writelog "INITBLOC" "Paramétrage du script de démontage du netlogon pour lightdm"
	touch /etc/lightdm/logonscript.sh
	addtoend /etc/lightdm/logonscript.sh "if mount | grep -q \"/tmp/netlogon\" ; then umount /tmp/netlogon ;fi"
	chmod +x /etc/lightdm/logonscript.sh

	touch /etc/lightdm/logoffscript.sh
	echo "sleep 2 \
umount -f /tmp/netlogon \ 
umount -f \$HOME
" > /etc/lightdm/logoffscript.sh
	chmod +x /etc/lightdm/logoffscript.sh

	########################################################################
	#paramétrage du lightdm.conf
	#activation du pavé numérique par greeter-setup-script=/usr/bin/numlockx on
	########################################################################
	writelog "---Paramétrage du lightdm.conf & pavé numérique"	
	echo "[SeatDefaults]
allow-guest=false
greeter-show-manual-login=true
greeter-hide-users=true
session-setup-script=/etc/lightdm/logonscript.sh
session-cleanup-script=/etc/lightdm/logoffscript.sh
greeter-setup-script=/usr/bin/numlockx on" > /usr/share/lightdm/lightdm.conf.d/50-no-guest.conf
	writelog "ENDBLOC"
fi

# echo "GVFS_DISABLE_FUSE=1" >> /etc/environment


# Modification ancien gestionnaire de session MDM
if [ "$(which mdm)" = "/usr/sbin/mdm" ] ; then # si MDM est installé (ancienne version de Mint <17.2)
	writelog "Modification de l'ancien gestionnaire de session MDM (pour Mint <17.2)"
	cp /etc/mdm/mdm.conf /etc/mdm/mdm_old.conf #backup du fichier de config de mdm
	wget --no-check-certificate https://raw.githubusercontent.com/dane-lyon/fichier-de-config/master/mdm.conf ; mv -f mdm.conf /etc/mdm/ ; 
fi

# Si Ubuntu Mate
if [ "$(which caja)" = "/usr/bin/caja" ] ; then
	writelog "Epuration du gestionnaire de session caja (pour Ubuntu Mate)"
	apt purge -y hexchat transmission-gtk ubuntu-mate-welcome cheese pidgin rhythmbox
	snap remove ubuntu-mate-welcome
fi

# Si Lubuntu (lxde)
if [ "$(which pcmanfm)" = "/usr/bin/pcmanfm" ] ; then
	writelog "Epuration du gestionnaire de session pcmanfm (pour Lubuntu LXDE)"
	apt purge -y abiword gnumeric pidgin transmission-gtk sylpheed audacious guvcview ;
fi

########################################################################
# Spécifique Gnome Shell
########################################################################
if [ "$(which gnome-shell)" = "/usr/bin/gnome-shell" ] ; then  # si GS installé
	writelog "INITBLOC" "Paramétrage de Gnome Shell"
	# Désactiver userlist pour GDM
	echo "user-db:user
	system-db:gdm
	file-db:/usr/share/gdm/greeter-dconf-defaults" > /etc/dconf/profile/gdm

	writelog "---Suppression de la liste des utilisateurs au login"
	mkdir /etc/dconf/db/gdm.d
	echo "[org/gnome/login-screen]
	# Do not show the user list
	disable-user-list=true" > /etc/dconf/db/gdm.d/00-login-screen

	writelog "---Application des modifications"
	dconf update

	writelog "---Suppression des icônes Amazon"
	apt purge -y ubuntu-web-launchers gnome-initial-setup

	writelog "Remplacement des snaps par défauts par la version apt (plus rapide)"
	snap remove gnome-calculator gnome-characters gnome-logs gnome-system-monitor
	apt install gnome-calculator gnome-characters gnome-logs gnome-system-monitor -y 
	
	writelog "ENDBLOC"
fi


########################################################################
#Paramétrage pour remplir pam_mount.conf
########################################################################
writelog "INITBLOC" "Paramétrage pour remplir pam_mount.conf" "---/media/Serveur_Scribe"
eclairng="<volume user=\"*\" fstype=\"cifs\" server=\"$scribe_def_ip\" path=\"eclairng\" mountpoint=\"/media/Serveur_Scribe\" />"
grep "/media/Serveur_Scribe" /etc/security/pam_mount.conf.xml  >/dev/null
if [ $? != 0 ]
then
  sed -i "/<\!-- Volume definitions -->/a\ $eclairng" /etc/security/pam_mount.conf.xml
else
  echo "eclairng déjà présent"
fi

writelog "---~/Documents => Perso (scribe)"
homes="<volume user=\"*\" fstype=\"cifs\" server=\"$scribe_def_ip\" path=\"perso\" mountpoint=\"~/Documents\" />"
grep "mountpoint=\"~\"" /etc/security/pam_mount.conf.xml  >/dev/null
if [ $? != 0 ]; then 
	sed -i "/<\!-- Volume definitions -->/a\ $homes" /etc/security/pam_mount.conf.xml
fi

writelog "---/tmp/netlogon (DomainAdmins)"
netlogon="<volume user=\"*\" fstype=\"cifs\" server=\"$scribe_def_ip\" path=\"netlogon\" mountpoint=\"/tmp/netlogon\"  sgrp=\"DomainUsers\" />"
grep "/tmp/netlogon" /etc/security/pam_mount.conf.xml  >/dev/null
if [ $? != 0 ]; then
  sed -i "/<\!-- Volume definitions -->/a\ $netlogon" /etc/security/pam_mount.conf.xml
fi

writelog "---Samba"
grep "<cifsmount>mount -t cifs //%(SERVER)/%(VOLUME) %(MNTPT) -o \"noexec,nosetuids,mapchars,cifsacl,serverino,nobrl,iocharset=utf8,user=%(USER),uid=%(USERUID)%(before=\\",\\" OPTIONS)\"</cifsmount>" /etc/security/pam_mount.conf.xml  >/dev/null
if [ $? != 0 ]; then
  sed -i "/<\!-- pam_mount parameters: Volume-related -->/a\ <cifsmount>mount -t cifs //%(SERVER)/%(VOLUME) %(MNTPT) -o \"noexec,nosetuids,mapchars,cifsacl,serverino,nobrl,iocharset=utf8,user=%(USER),uid=%(USERUID)%(before=\\",\\" OPTIONS),vers=1.0\"</cifsmount>" /etc/security/pam_mount.conf.xml
fi
writelog "ENDBLOC"
########################################################################
#/etc/profile
########################################################################
writelog "Inscription de fr_FR dans /etc/profile"
addtoend /etc/profile "export LC_ALL=fr_FR.utf8" "export LANG=fr_FR.utf8" "export LANGUAGE=fr_FR.utf8" 2>> $logfile

########################################################################
#ne pas créer les dossiers par défaut dans home
########################################################################
writelog "Suppression de la création des dossiers par défaut dans home"
sed -i "s/enabled=True/enabled=False/g" /etc/xdg/user-dirs.conf

########################################################################
# les profs peuvent sudo
########################################################################
writelog "Ajout des professeurs (et admin) dans la liste des sudoers"
grep "%professeurs ALL=(ALL) ALL" /etc/sudoers > /dev/null
if [ $? != 0 ]; then
  sed -i "/%admin ALL=(ALL) ALL/a\%professeurs ALL=(ALL) ALL" /etc/sudoers
  sed -i "/%admin ALL=(ALL) ALL/a\%DomainAdmins ALL=(ALL) ALL" /etc/sudoers
fi

writelog "Suppression de paquet inutile sous Ubuntu/Unity"
apt purge -y aisleriot gnome-mahjongg pidgin transmission-gtk gnome-mines gnome-sudoku blueman abiword gnumeric thunderbird 2>> $logfile;

grep "LinuxMint" /etc/lsb-release > /dev/null
if [ $? != 0 ]; then
	writelog "Suppression de MintWelcome (sous Mint)"
	apt purge -y mintwelcome 2>> $logfile;
fi

writelog "Suppression de l'envoi des rapport d'erreurs"
echo "enabled=0" > /etc/default/apport

#writelog "suppression de l'applet network-manager"
#mv /etc/xdg/autostart/nm-applet.desktop /etc/xdg/autostart/nm-applet.old

writelog "suppression du menu messages"
apt purge -y indicator-messages  2>> $logfile

writelog "Changement page d'accueil firefox"
addtoend /usr/lib/firefox/defaults/pref/channel-prefs.js "$pagedemarragepardefaut"  2>> $logfile

writelog "Installation de logiciels basiques"
apt install -y vim htop 2>> $logfile

writelog "Gestion lecture de DVD"
# Lecture DVD sur Ubuntu 16.04 et supérieur ## répondre oui aux question posés...
#apt install -y libdvd-pkg ; dpkg-reconfigure libdvd-pkg

# Lecture DVD sur Ubuntu 14.04
if [ "$version" = "trusty" ] ; then
	apt install -y libdvdread4 && bash /usr/share/doc/libdvdread4/install-css.sh 2>> $logfile
fi

# Résolution problème dans certains cas uniquement pour Trusty (exemple pour lancer gedit directement avec : sudo gedit)
if [ "$version" = "trusty" ] ; then
	addtoend /etc/sudoers 'Defaults        env_keep += "DISPLAY XAUTHORITY"' 2>> $logfile
fi

# Spécifique base 16.04 ou 18.04 : pour le fonctionnement du dossier /etc/skel 
if [ "$version" = "xenial" ] || [ "$version" = "bionic" ]  || [ "$version" = "focal" ] ; then
	sed -i "30i\session optional        pam_mkhomedir.so" /etc/pam.d/common-session
fi

if [ "$version" = "bionic" ] || [ "$version" = "focal" ] ; then
	writelog "Création de raccourci sur le bureau + dans dossier utilisateur"
	# (pour la 18.04 uniquement) pour l'accès aux partages (commun+perso+lespartages)
	tar -xzf skel.tar.gz -C /etc/ 2>> $logfile
	rm -f skel.tar.gz
fi

# Suppression de notification de mise à niveau
writelog "Suppression de notification de mise à niveau" 
sed -r -i 's/Prompt=lts/Prompt=never/g' /etc/update-manager/release-upgrades

# Enchainer sur un script de Postinstallation
if [ "$postinstallbase" = "yes" ]; then 
	writelog "INITBLOC" "PostInstallation basique"
	mv ./$second_dir/ubuntu-et-variantes-postinstall.sh . 2>> $logfile
	chmod +x ubuntu-et-variantes-postinstall.sh 2>> $logfile ; ./ubuntu-et-variantes-postinstall.sh 2>> $logfile ; rm -f ubuntu-et-variantes-postinstall.sh 2>> $logfile ;
	writelog "ENDBLOC"
fi

writelog "Installation du gestionnaire de raccourcis"
apt-get install xbindkeys xbindkeys-config -y 2>> $logfile

writelog "Gestion des partitions exfat"
apt-get install -y exfat-utils exfat-fuse 2>> $logfile

if [ "$postinstalladditionnel" = "yes" ]; then 
	if [ "$version" = "bionic" ] || [ "$version" = "focal" ]; then
		writelog "INITBLOC" "PostInstallation avancée"
		sudo -u $localadmin wget --no-check-certificate https://github.com/simbd/Ubuntu_20.04LTS_PostInstall/archive/master.zip 2>> $logfile
		sudo -u $localadmin unzip master.zip -d . 2>> $logfile
		sudo -u $localadmin chmod +x Ubuntu_20.04LTS_PostInstall-master/*.sh  2>> $logfile
		sudo -u $localadmin ./Ubuntu_20.04LTS_PostInstall-master/Postinstall_Ubuntu-20.04LTS_FocalFossa.sh 2>> $logfile
		sudo -u $localadmin rm -fr master.zip Ubuntu_20.04LTS_PostInstall-master 2>> $logfile;
		writelog "ENDBLOC"
	fi
fi

writelog "Nettoyage de la station avant clonage"
apt-get -y autoremove --purge 2>> $logfile ; apt-get -y clean 2>> $logfile
clear

writelog "FIN de l'integration"
if [ "$reboot" = "yes" ]; then
	reboot
else
	echo "Pensez à redémarrer avant toute nouvelle opération sensible"
fi
