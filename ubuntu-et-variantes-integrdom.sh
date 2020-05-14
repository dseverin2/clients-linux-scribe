#!/bin/bash
# version 2.3.9
# Dernière modification : 14/05/2020-2 (amélioration invocation script PostInstall)


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

# Pour identifier le numéro de la version (14.04, 16.04...)
. /etc/lsb-release

# Affectation à la variable "version" suivant la variante utilisé
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

########################################################################
# Vérification de version
########################################################################

if [ "$version" == "unsupported" ]; then
  echo "Désolé, vous n'êtes pas sur une version compatible !"
  exit
fi

my_dir="$(dirname "$0")"
source $my_dir/config.cfg

read -p "Voulez-vous configurer la photocopieuse SdP (O/[N]): " config_photocopieuse
if [ $config_photocopieuse -eq "o" ] || [ $config_photocopieuse -eq "O" ]; then
	./setup_photocopieuse.sh
fi

echo "Adresse du serveur Scribe = $scribe_def_ip"

#############################################
# Modification du /etc/wgetrc.
#############################################
grep "proxy-password = $scribepass" /etc/wgetrc > /dev/null
if [ $? != 0 ]
	then
		echo "
https_proxy = $proxy_wgetrc/
http_proxy = $proxy_wgetrc/
ftp_proxy = $proxy_wgetrc/
use_proxy=on
proxy-user = $scribeuserapt
proxy-password = $scribepass" >> /etc/wgetrc
fi

###################################################
# cron d'extinction automatique à lancer ?
###################################################

if [ "$extinction" != "" ]; then
	echo "0 $extinction * * * root /sbin/shutdown -h now" > /etc/cron.d/prog_extinction
fi

##############################################################################
### Utilisation du Script Esubuntu ?
##############################################################################


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

  echo "Paramétrage du proxy $proxy_def_ip:$proxy_def_port" 

#Paramétrage des paramètres Proxy pour Gnome
#######################################################
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

  glib-compile-schemas /usr/share/glib-2.0/schemas

#Paramétrage du Proxy pour le système
######################################################################
echo "http_proxy=http://$proxy_def_ip:$proxy_def_port/
https_proxy=http://$proxy_def_ip:$proxy_def_port/
ftp_proxy=http://$proxy_def_ip:$proxy_def_port/
no_proxy=\"$proxy_env_noproxy\"" >> /etc/environment

#Paramétrage du Proxy pour apt
######################################################################
echo "Acquire::http::proxy \"http://$proxy_def_ip:$proxy_def_port/\";
Acquire::ftp::proxy \"ftp://$proxy_def_ip:$proxy_def_port/\";
Acquire::https::proxy \"https://$proxy_def_ip:$proxy_def_port/\";" > /etc/apt/apt.conf.d/20proxy

#Permettre d'utiliser la commande add-apt-repository derrière un Proxy
######################################################################
echo "Defaults env_keep = https_proxy" >> /etc/sudoers

fi

# Modification pour ne pas avoir de problème lors du rafraichissement des dépots avec un proxy
# cette ligne peut être commentée/ignorée si vous n'utilisez pas de proxy ou avec la 14.04.
echo "Acquire::http::No-Cache true;" >> /etc/apt/apt.conf
echo "Acquire::http::Pipeline-Depth 0;" >> /etc/apt/apt.conf


# Vérification que le système est bien à jour
apt update ; apt full-upgrade -y

# Ajout de Net-tools pour ifconfig en 18.04 et futures versions
apt install -y net-tools

####################################################
# Téléchargement + Mise en place de Esubuntu (si activé)
####################################################
if [ "$esubuntu" = "yes" ] ; then 
	# Téléchargement des paquets
	## Précision : en raison des problèmes que pose l'https pour le téléchargement dans les établissements, l'archive est ré-hebergé sur un ftp free :
	if [ -e $second_dir/Esubuntu-master.zip ]; then
		cp $second_dir/Esubuntu-master.zip .
	else  
		wget --no-check-certificate https://github.com/dseverin2/clients-linux-scribe/archive/master.zip #(pose problème lors des tests)
		if [ -e $second_dir/master.zip ]; then
			echo "Esubuntu-master récupéré sur github"
			unzip master.zip
			mv clients-linux-scribe-master/Esubuntu-master .
			rm -fr clients-linux-scribe-master
		else
			wget http://nux87.free.fr/pour_script_integrdom/master.7z
			echo "Esubuntu-master récupéré sur nux87.free.fr"
		fi
	fi

	# Déplacement/extraction de l'archive + lancement par la suite
	7z x Esubuntu-master.7z ; rm -r Esubuntu-master.7z ; chmod -R +x Esubuntu-master
	./Esubuntu-master/install_esubuntu.sh

	# Mise en place des wallpapers pour les élèves, profs, admin 
	if [ -e $second_dir/wallpaper.zip ]; then
		cp $second_dir/wallpaper.zip .
	else  
		wget https://github.com/dane-lyon/fichier-de-config/raw/master/wallpaper.zip
		if [ -e wallpaper.zip ]; then
			echo "wallpaper.zip récupéré sur github"
		else
			wget http://nux87.free.fr/esu_ubuntu/wallpaper.zip
			echo "wallpaper.zip récupéré sur nux87.free.fr"
		fi
	fi
	
	unzip wallpaper.zip ; rm -r wallpaper.zip
	mv wallpaper /usr/share/
fi

########################################################################
#Mettre la station à l'heure à partir du serveur Scribe
########################################################################
apt install -y ntpdate ;
ntpdate $scribe_def_ip

########################################################################
#installation des paquets nécessaires
#numlockx pour le verrouillage du pavé numérique
#unattended-upgrades pour forcer les mises à jour de sécurité à se faire
########################################################################
apt install -y ldap-auth-client libpam-mount cifs-utils nscd numlockx unattended-upgrades

########################################################################
# activation auto des mises à jour de sécurité
########################################################################
echo "APT::Periodic::Update-Package-Lists \"1\";
APT::Periodic::Unattended-Upgrade \"1\";" > /etc/apt/apt.conf.d/20auto-upgrades

########################################################################
# Configuration du fichier pour le LDAP /etc/ldap.conf
########################################################################
echo "
# /etc/ldap.conf
host $scribe_def_ip
base o=gouv, c=fr
nss_override_attribute_value shadowMax 9999
" > /etc/ldap.conf

########################################################################
# activation des groupes des users du ldap
########################################################################
echo "Name: activate /etc/security/group.conf
Default: yes
Priority: 900
Auth-Type: Primary
Auth:
        required                        pam_group.so use_first_pass" > /usr/share/pam-configs/my_groups

########################################################################
#auth ldap
########################################################################
echo "[open_ldap]
nss_passwd=passwd:  files ldap
nss_group=group: files ldap
nss_shadow=shadow: files ldap
nss_netgroup=netgroup: nis
" > /etc/auth-client-config/profile.d/open_ldap

########################################################################
#application de la conf nsswitch
########################################################################
auth-client-config -t nss -p open_ldap

########################################################################
#modules PAM mkhomdir pour pam-auth-update
########################################################################
echo "Name: Make Home directory
Default: yes
Priority: 128
Session-Type: Additional
Session:
       optional                        pam_mkhomedir.so silent" > /usr/share/pam-configs/mkhomedir

grep "auth    required     pam_group.so use_first_pass"  /etc/pam.d/common-auth  >/dev/null
if [ $? == 0 ]
then
  echo "/etc/pam.d/common-auth Ok"
else
  echo  "auth    required     pam_group.so use_first_pass" >> /etc/pam.d/common-auth
fi

########################################################################
# mise en place de la conf pam.d
########################################################################
pam-auth-update consolekit ldap libpam-mount unix mkhomedir my_groups --force

########################################################################
# mise en place des groupes pour les users ldap dans /etc/security/group.conf
########################################################################
grep "*;*;*;Al0000-2400;floppy,audio,cdrom,video,plugdev,scanner,dialout" /etc/security/group.conf  >/dev/null; 

if [ $? != 0 ] ; then 
  echo "*;*;*;Al0000-2400;floppy,audio,cdrom,video,plugdev,scanner,dialout" >> /etc/security/group.conf 
  else echo "group.conf ok"
fi

########################################################################
#on remet debconf dans sa conf initiale
########################################################################
export DEBIAN_FRONTEND="dialog"
export DEBIAN_PRIORITY="high"

########################################################################
#paramétrage du script de démontage du netlogon pour lightdm 
########################################################################
if [ "$(which lightdm)" = "/usr/sbin/lightdm" ] ; then #Si lightDM présent
  touch /etc/lightdm/logonscript.sh
  grep "if mount | grep -q \"/tmp/netlogon\" ; then umount /tmp/netlogon ;fi" /etc/lightdm/logonscript.sh  >/dev/null
  if [ $? == 0 ] ; then
    echo "Présession Ok"
  else
    echo "if mount | grep -q \"/tmp/netlogon\" ; then umount /tmp/netlogon ;fi" >> /etc/lightdm/logonscript.sh
  fi
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
  echo "[SeatDefaults]
      allow-guest=false
      greeter-show-manual-login=true
      greeter-hide-users=true
      session-setup-script=/etc/lightdm/logonscript.sh
      session-cleanup-script=/etc/lightdm/logoffscript.sh
      greeter-setup-script=/usr/bin/numlockx on" > /usr/share/lightdm/lightdm.conf.d/50-no-guest.conf
fi

# echo "GVFS_DISABLE_FUSE=1" >> /etc/environment


# Modification ancien gestionnaire de session MDM
if [ "$(which mdm)" = "/usr/sbin/mdm" ] ; then # si MDM est installé (ancienne version de Mint <17.2)
  cp /etc/mdm/mdm.conf /etc/mdm/mdm_old.conf #backup du fichier de config de mdm
  wget --no-check-certificate https://raw.githubusercontent.com/dane-lyon/fichier-de-config/master/mdm.conf ; mv -f mdm.conf /etc/mdm/ ; 
fi

# Si Ubuntu Mate
if [ "$(which caja)" = "/usr/bin/caja" ] ; then
  apt purge -y hexchat transmission-gtk ubuntu-mate-welcome cheese pidgin rhythmbox
  snap remove ubuntu-mate-welcome
fi

# Si Lubuntu (lxde)
if [ "$(which pcmanfm)" = "/usr/bin/pcmanfm" ] ; then
  apt purge -y abiword gnumeric pidgin transmission-gtk sylpheed audacious guvcview ;
fi

########################################################################
# Spécifique Gnome Shell
########################################################################
if [ "$(which gnome-shell)" = "/usr/bin/gnome-shell" ] ; then  # si GS installé

	# Désactiver userlist pour GDM
	echo "user-db:user
	system-db:gdm
	file-db:/usr/share/gdm/greeter-dconf-defaults" > /etc/dconf/profile/gdm

	mkdir /etc/dconf/db/gdm.d
	echo "[org/gnome/login-screen]
	# Do not show the user list
	disable-user-list=true" > /etc/dconf/db/gdm.d/00-login-screen

	#prise en compte du changement
	dconf update

	# Suppression icone Amazon
	apt purge -y ubuntu-web-launchers gnome-initial-setup

	# Remplacement des snaps par défauts par la version apt (plus rapide)
	snap remove gnome-calculator gnome-characters gnome-logs gnome-system-monitor
	apt install gnome-calculator gnome-characters gnome-logs gnome-system-monitor -y 

fi


########################################################################
#Paramétrage pour remplir pam_mount.conf
########################################################################

eclairng="<volume user=\"*\" fstype=\"cifs\" server=\"$scribe_def_ip\" path=\"eclairng\" mountpoint=\"/media/Serveur_Scribe\" />"
grep "/media/Serveur_Scribe" /etc/security/pam_mount.conf.xml  >/dev/null
if [ $? != 0 ]
then
  sed -i "/<\!-- Volume definitions -->/a\ $eclairng" /etc/security/pam_mount.conf.xml
else
  echo "eclairng déjà présent"
fi

homes="<volume user=\"*\" fstype=\"cifs\" server=\"$scribe_def_ip\" path=\"perso\" mountpoint=\"~/Documents\" />"
grep "mountpoint=\"~\"" /etc/security/pam_mount.conf.xml  >/dev/null
if [ $? != 0 ]
then sed -i "/<\!-- Volume definitions -->/a\ $homes" /etc/security/pam_mount.conf.xml
else
  echo "homes déjà présent"
fi

netlogon="<volume user=\"*\" fstype=\"cifs\" server=\"$scribe_def_ip\" path=\"netlogon\" mountpoint=\"/tmp/netlogon\"  sgrp=\"DomainUsers\" />"
grep "/tmp/netlogon" /etc/security/pam_mount.conf.xml  >/dev/null
if [ $? != 0 ]
then
  sed -i "/<\!-- Volume definitions -->/a\ $netlogon" /etc/security/pam_mount.conf.xml
else
  echo "netlogon déjà présent"
fi

grep "<cifsmount>mount -t cifs //%(SERVER)/%(VOLUME) %(MNTPT) -o \"noexec,nosetuids,mapchars,cifsacl,serverino,nobrl,iocharset=utf8,user=%(USER),uid=%(USERUID)%(before=\\",\\" OPTIONS)\"</cifsmount>" /etc/security/pam_mount.conf.xml  >/dev/null
if [ $? != 0 ]
then
  sed -i "/<\!-- pam_mount parameters: Volume-related -->/a\ <cifsmount>mount -t cifs //%(SERVER)/%(VOLUME) %(MNTPT) -o \"noexec,nosetuids,mapchars,cifsacl,serverino,nobrl,iocharset=utf8,user=%(USER),uid=%(USERUID)%(before=\\",\\" OPTIONS),vers=1.0\"</cifsmount>" /etc/security/pam_mount.conf.xml
else
  echo "mount.cifs déjà présent"
fi

########################################################################
#/etc/profile
########################################################################
echo "
export LC_ALL=fr_FR.utf8
export LANG=fr_FR.utf8
export LANGUAGE=fr_FR.utf8
" >> /etc/profile

########################################################################
#ne pas créer les dossiers par défaut dans home
########################################################################
sed -i "s/enabled=True/enabled=False/g" /etc/xdg/user-dirs.conf

########################################################################
# les profs peuvent sudo
########################################################################
grep "%professeurs ALL=(ALL) ALL" /etc/sudoers > /dev/null
if [ $? != 0 ]
then
  sed -i "/%admin ALL=(ALL) ALL/a\%professeurs ALL=(ALL) ALL" /etc/sudoers
  sed -i "/%admin ALL=(ALL) ALL/a\%DomainAdmins ALL=(ALL) ALL" /etc/sudoers
else
  echo "prof déjà dans sudo"
fi

# Suppression de paquet inutile sous Ubuntu/Unity
apt purge -y aisleriot gnome-mahjongg ;

# Pour être sûr que les paquets suivant (parfois présent) ne sont pas installés :
apt purge -y pidgin transmission-gtk gnome-mines gnome-sudoku blueman abiword gnumeric thunderbird mintwelcome ;


########################################################################
#suppression de l'envoi des rapport d'erreurs
########################################################################
echo "enabled=0" > /etc/default/apport

########################################################################
#suppression de l'applet network-manager
########################################################################
#mv /etc/xdg/autostart/nm-applet.desktop /etc/xdg/autostart/nm-applet.old

########################################################################
#suppression du menu messages
########################################################################
apt purge -y indicator-messages 

# Changement page d'accueil firefox
echo "user_pref(\"browser.startup.homepage\", \"$pagedemarragepardefaut\");" >> /usr/lib/firefox/defaults/pref/channel-prefs.js

# Logiciels utiles
apt install -y vim htop

# Lecture DVD sur Ubuntu 16.04 et supérieur ## répondre oui aux question posés...
#apt install -y libdvd-pkg ; dpkg-reconfigure libdvd-pkg

# Lecture DVD sur Ubuntu 14.04
if [ "$version" = "trusty" ] ; then
  apt install -y libdvdread4 && bash /usr/share/doc/libdvdread4/install-css.sh
fi

# Résolution problème dans certains cas uniquement pour Trusty (exemple pour lancer gedit directement avec : sudo gedit)
if [ "$version" = "trusty" ] ; then
  echo 'Defaults        env_keep += "DISPLAY XAUTHORITY"' >> /etc/sudoers
fi

# Spécifique base 16.04 ou 18.04 : pour le fonctionnement du dossier /etc/skel 
if [ "$version" = "xenial" ] || [ "$version" = "bionic" ] ; then
  sed -i "30i\session optional        pam_mkhomedir.so" /etc/pam.d/common-session
fi

if [ "$version" = "bionic" ] ; then
  # Création de raccourci sur le bureau + dans dossier utilisateur (pour la 18.04 uniquement) pour l'accès aux partages (commun+perso+lespartages)
	if [ -e /$second_dir/skel.tar.gz ]; then  
		cp $second_dir/skel.tar.gz .
	else
		wget http://nux87.free.fr/pour_script_integrdom/skel.tar.gz
	fi
  tar -xzf skel.tar.gz -C /etc/
  rm -f skel.tar.gz
fi

# Suppression de notification de mise à niveau 
sed -r -i 's/Prompt=lts/Prompt=never/g' /etc/update-manager/release-upgrades

# Enchainer sur un script de Postinstallation
if [ "$postinstallbase" = "yes" ]; then 
	if [ -e $second_dir/ubuntu-et-variantes-postinstall.sh  ] ; then # Pour 14.04/16.04/18.04/20.04
		cp $second_dir/ubuntu-et-variantes-postinstall.sh .
	else
	  wget --no-check-certificate https://raw.githubusercontent.com/dane-lyon/clients-linux-scribe/master/ubuntu-et-variantes-postinstall.sh 
	fi
	chmod +x ubuntu-et-variantes-postinstall.sh ; ./ubuntu-et-variantes-postinstall.sh ; rm -f ubuntu-et-variantes-postinstall.sh ;
fi

if [ "$postinstalladditionnel" = "yes" ]; then 
	if [ "$version" = "bionic" ]; then
		if [ -e $second_dir/Ubuntu18.04_Bionic_Postinstall.sh ] ; then # Pour 18.04 uniquement
			cp $second_dir/Ubuntu18.04_Bionic_Postinstall.sh .
		else
			 wget --no-check-certificate https://github.com/simbd/Scripts_Ubuntu/blob/master/Ubuntu18.04_Bionic_Postinstall.sh
		fi
		chmod +x Ubuntu18.04_Bionic_Postinstall.sh ; ./Ubuntu18.04_Bionic_Postinstall.sh ; rm -f Ubuntu*.sh ;
	elif [ "$version" = "focal" ]; then
		if [ -e $second_dir/Postinstall_Ubuntu-20.04LTS_FocalFossa.sh ] ; then # Pour 20.04 uniquement, on doit lancer avec l'admin local (obligation imposée par le script de PostInstall)
			cp $second_dir/Postinstall_Ubuntu-20.04LTS_FocalFossa.sh .
		else
			 sudo -u $localadmin wget --no-check-certificate https://github.com/simbd/Ubuntu_20.04LTS_PostInstall/archive/master.zip
			 sudo -u $localadmin unzip master.zip -d .
			 sudo -u $localadmin rm -f master.zip
		fi
		sudo -u $localadmin mv Ubuntu_20.04LTS_PostInstall-master/* .
		sudo -u $localadmin chmod +x Postinstall_Ubuntu-20.04LTS_FocalFossa.sh ; sudo -u $localadmin ./Postinstall_Ubuntu-20.04LTS_FocalFossa.sh
		sudo -u $localadmin rm -f Postinstall_Ubuntu-20.04LTS_FocalFossa.sh Config_Function.sh Description_logiciel.fr README.md Zenity_default_choice.sh Ubuntu_20.04LTS_PostInstall-master;
fi

echo "INSTALLATION DU GESTIONNAIRE DE RACCOURCIS"
apt-get install xbindkeys xbindkeys-config -y


# Installation quelque soit la variante et la version 
echo "Gestion des partitions exfat"
apt-get install -y exfat-utils exfat-fuse

########################################################################
#nettoyage station avant clonage
########################################################################
apt-get -y autoremove --purge ; apt-get -y clean ; clear

########################################################################
#FIN
########################################################################
echo "C'est fini ! Un reboot est nécessaire..."
read -p "Voulez-vous redémarrer immédiatement ? [O/n] " rep_reboot
if [ "$rep_reboot" = "O" ] || [ "$rep_reboot" = "o" ] || [ "$rep_reboot" = "" ] ; then
  reboot
fi
