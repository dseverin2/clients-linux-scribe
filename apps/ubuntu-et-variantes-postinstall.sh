#!/bin/bash
# version 2.0.4 (05/03/20)

# Ce script sert à installer des logiciels supplémentaires utiles pour les collèges & lyçées
# Ce script est utilisable pour Ubuntu et variantes en 14.04, 16.04, 18.04, 20.04

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

# désactiver mode intéractif pour automatiser l'installation de wireshark
export DEBIAN_FRONTEND="noninteractive"

# Ajout dépot partenaire
add-apt-repository "deb http://archive.canonical.com/ubuntu $(lsb_release -sc) partner" 
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CB2DE8E5

# Vérification que le système est à jour
apt-get update ; apt-get -y dist-upgrade

# Installation d'onlyoffice
#apt-get install onlyoffice-desktopeditors
wget -e use_proxy=yes -e http_proxy=$proxy_params --no-check-certificate https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb
if [ -e onlyoffice-desktopeditors_amd64.deb ]
	then
		echo "onlyoffice-desktopeditors_amd64.deb récupéré avec succès"
	else
		cp $second_dir/onlyoffice-desktopeditors_amd64.deb .
  fi
dpkg -i onlyoffice-desktopeditors_amd64.deb ; apt-get -fy install ; rm -f onlyoffice-desktopeditors_amd64.deb

#########################################
# Paquets uniquement pour Trusty (14.04)
#########################################
if [ "$version" = "trusty" ] ; then
  # paquet
  apt-get -y install idle-python3.4 gstreamer0.10-plugins-ugly celestia

  # Backportage LibreOffice (sinon version trop ancienne sur la 14.04)
  add-apt-repository -y ppa:libreoffice/ppa ; apt-get update ; apt-get -y upgrade
  
  # Google Earth
  apt-get -y install libfontconfig1:i386 libx11-6:i386 libxrender1:i386 libxext6:i386 libgl1-mesa-glx:i386 libglu1-mesa:i386 libglib2.0-0:i386 libsm6:i386
  wget -e use_proxy=yes -e http_proxy=$proxy_params  https://dl.google.com/dl/earth/client/current/google-earth-stable_current_i386.deb --no-check-certificate; 
  dpkg -i google-earth-stable_current_i386.deb ; apt-get -fy install ; rm -f google-earth-stable_current_i386.deb   
fi

#########################################
# Paquets uniquement pour Xenial (16.04)
#########################################
if [ "$version" = "xenial" ] ; then

  # Installation style "Breeze" pour LibreOffice si il est n'est pas installé (exemple : Xubuntu 16.04...)
  apt install -y libreoffice-style-breeze ;
  # paquet
  apt install -y idle-python3.5 x265 ;
  
  # Backportage LibreOffice (si besoin de backporter LO, décommenter !)
  add-apt-repository -y ppa:libreoffice/ppa ; apt update ; apt upgrade -y

  # Google Earth
  wget -e use_proxy=yes -e http_proxy=$proxy_params --no-check-certificate https://dl.google.com/dl/earth/client/current/google-earth-stable_current_amd64.deb 
  wget -e use_proxy=yes -e http_proxy=$proxy_params --no-check-certificate http://ftp.fr.debian.org/debian/pool/main/l/lsb/lsb-core_4.1+Debian13+nmu1_amd64.deb
  wget -e use_proxy=yes -e http_proxy=$proxy_params --no-check-certificate http://ftp.fr.debian.org/debian/pool/main/l/lsb/lsb-security_4.1+Debian13+nmu1_amd64.deb 
  dpkg -i lsb*.deb ; dpkg -i google-earth*.deb ; apt install -fy ; rm -f lsb*.deb && rm -f google-earth*.deb
  
  # Celestia
  wget -e use_proxy=yes -e http_proxy=$proxy_params --no-check-certificate https://gitlab.com/simbd/Scripts_Ubuntu/-/blob/7925144bf30ed4c353b9676521d591dc35c97dde/Celestia_pour_Bionic.sh
if [ -e Celestia_pour_Bionic.sh ]
	then
		echo "Celestia_pour_Bionic.sh récupéré avec succès"
	else
		cp $second_dir/Celestia_pour_Bionic.sh .
  fi
  chmod +x Celestia_pour_Bionic.sh ; ./Celestia_pour_Bionic.sh ; rm Celestia*
fi

#########################################
# Paquet uniquement pour Bionic (18.04)
#########################################
if [ "$version" = "bionic" ] ; then
  # paquet
  apt-get install -y idle-python3.6 x265

  # Google Earth Pro x64 
  wget -e use_proxy=yes -e http_proxy=$proxy_params --no-check-certificate https://dl.google.com/dl/earth/client/current/google-earth-pro-stable_current_amd64.deb ; dpkg -i google-earth-pro-stable_current_amd64.deb ; apt install -fy
  rm /etc/apt/sources.list.d/google-earth* ; rm google-earth-pro* #dépot google retiré volontairement
  
  # Celestia
  wget -e use_proxy=yes -e http_proxy=$proxy_params --no-check-certificate https://gitlab.com/simbd/Scripts_Ubuntu/-/blob/7925144bf30ed4c353b9676521d591dc35c97dde/Celestia_pour_Bionic.sh
  if [ -e Celestia_pour_Bionic.sh ]
	then
		echo "Celestia_pour_Bionic.sh récupéré avec succès sur github"
	else
		cp $second_dir/Celestia_pour_Bionic.sh .
  fi
  chmod +x Celestia_pour_Bionic.sh ; ./Celestia_pour_Bionic.sh ; rm Celestia*
  
  # Pilote imprimante openprinting
  apt-get install -y openprinting-ppds
fi

#########################################
# Paquet uniquement pour Focal (20.04)
#########################################
if [ "$version" = "focal" ] ; then
  # paquet
  apt-get install -y idle-python3.7 x265

  # Google Earth Pro x64 
  wget -e use_proxy=yes -e http_proxy=$proxy_params --no-check-certificate https://dl.google.com/dl/earth/client/current/google-earth-pro-stable_current_amd64.deb ; dpkg -i google-earth-pro-stable_current_amd64.deb ; apt install -fy
  rm /etc/apt/sources.list.d/google-earth* ; rm google-earth-pro* #dépot google retiré volontairement
  
  # Celestia
  #wget -e use_proxy=yes -e http_proxy=$proxy_params --no-check-certificate https://futureadressegit/Celestia_pour_focal.sh
  if [ -e Celestia_pour_focal.sh ]
	then
		echo "Celestia_pour_focal.sh récupéré avec succès sur github"
	else
		cp $second_dir/Celestia_pour_focal.sh .
  fi
  chmod +x Celestia_pour_focal.sh ; ./Celestia_pour_focal.sh ; rm Celestia*
  
  # Pilote imprimante openprinting
  apt-get install -y openprinting-ppds
fi

#=======================================================================================================#

if [ "$version" != "bionic" ] && [ "$version" != "focal"] ; then  # Installation spécifique pour 14.04 ou 16.04
  # drivers imprimantes (sauf pour Bionic ou il est installé différemment)
  wget -e use_proxy=yes -e http_proxy=$proxy_params --no-check-certificate http://www.openprinting.org/download/printdriver/debian/dists/lsb3.2/contrib/binary-amd64/openprinting-gutenprint_5.2.7-1lsb3.2_amd64.deb
  dpkg -i openprinting-gutenprint_5.2.7-1lsb3.2_amd64.deb ; apt-get -fy install ; rm openprinting-gutenprint*
  
  # Gdevelop (PPA pas encore actif pour la 18.04)
  add-apt-repository -y ppa:florian-rival/gdevelop
  apt-get update ; apt-get -y install gdevelop
fi

# drivers pour les scanners les plus courants
apt-get -y install sane

# Police d'écriture de Microsoft
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | /usr/bin/debconf-set-selections | apt-get -y install ttf-mscorefonts-installer ;

# Oracle Java 8
add-apt-repository -y ppa:webupd8team/java ; apt-get update ; echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections | apt-get -y install oracle-java8-installer

#[ Bureautique ]
apt-get -y install libreoffice libreoffice-gtk libreoffice-l10n-fr freeplane scribus gnote xournal cups-pdf

#[ Web ]
apt-get -y install chromium-browser chromium-browser-l10n ;
apt-get -y install adobe-flashplugin ; #permet d'avoir flash en même temps pour firefox et chromium

#[ Video / Audio ]
apt-get -y install imagination openshot audacity vlc x264 ffmpeg2theora flac vorbis-tools lame oggvideotools mplayer ogmrip goobox

#[ Graphisme / Photo ]
apt-get -y install blender sweethome3d gimp pinta inkscape gthumb mypaint hugin shutter

#[ Système ]
apt-get -y install gparted vim pyrenamer rar unrar htop diodon p7zip-full gdebi

# Wireshark
debconf-set-selections <<< "wireshark-common/install-setuid true"
apt-get -y install wireshark 
sed -i -e "s/,dialout/,dialout,wireshark/g" /etc/security/group.conf

#[ Mathématiques ]
apt-get -y install algobox carmetal scilab

#[ Sciences ]
apt-get -y install stellarium avogadro 

#[ Programmation ]
apt-get -y install ghex geany imagemagick gcolor2
apt-get -y install python3-pil.imagetk python3-pil traceroute python3-tk #python3-sympy
if [ -e $second_dir/scratch-desktop_3.3.0_amd64.deb ]; then
	cp $second_dir/scratch-desktop_3.3.0_amd64.deb .
else
	wget -e use_proxy=yes -e http_proxy=$proxy_params https://github.com/redshaderobotics/scratch3.0-linux/releases/download/3.3.0/scratch-desktop_3.3.0_amd64.deb 
fi
dpkg -i scratch-desktop_3.3.0_amd64.deb ; apt install -fy ; rm scratch-desktop_3.3.0_amd64.deb 

#[ Serveur ]
if [ "$ansible" = "yes" ]; then
	apt-get -y install openssh-server
fi

### Supplément de logiciel proposé dans la section wpkg du forum de la dane en version linux (pour Ubuntu 18.04)
### cf : https://forum-dane.ac-lyon.fr/forum/viewforum.php?f=44
if [ "$version" = "bionic" ] || [ "$version" = "focal" ] ; then
  # Openboard
  if [ "$version" = "bionic" ]; then
	  #wget -e use_proxy=yes -e http_proxy=$proxy_params --no-check-certificate https://gitlab.com/simbd/Scripts_Ubuntu/-/blob/7925144bf30ed4c353b9676521d591dc35c97dde/Openboard_1804.sh
	  if [ -e Openboard_1804.sh  ]
		then
			echo "Openboard_1804.sh  récupéré avec succès sur gitlab"
		else
			cp $second_dir/Openboard_1804.sh  .
	  fi
	  chmod +x Openboard* && ./Openboard_1804.sh ; rm Openboard* 
  elif [ "$version" = "focal" ]; then
	./installOpenBoard.sh
  fi
  # Openshot-qt, Gshutdown, X-Cas, Planner, extension ooohg, winff, optgeo, ghostscript
  apt install openshot-qt gshutdown xcas planner ooohg winff winff-qt optgeo ghostscript -y #gshutdown équivalent à poweroff
  # GanttProject
  apt install openjdk-8-jre oenjdk-11-jre java-11-amazon-corretto-jdk bellsoft-java11-runtime
  wget -e use_proxy=yes -e http_proxy=$proxy_params --no-check-certificate https://www.ganttproject.biz/dl/2.8.11/lin && dpkg -i ganttproject* ; apt install -fy ; rm ganttproject*
  # mBlock
  apt install libgconf-2-4 -y ; wget http://mblock.makeblock.com/mBlock4.0/mBlock_4.0.4_amd64.deb ; dpkg -i mBlock*.deb ; apt install -fy ; rm mBlock*.deb      
  # Xia (alias ImageActive)
  echo "deb http://repository.crdp.ac-versailles.fr/debian xia main" | tee /etc/apt/sources.list.d/xia.list
  wget -e use_proxy=yes -e http_proxy=$proxy_params -q http://repository.crdp.ac-versailles.fr/crdp.gpg -O - | apt-key add - ; apt update ; apt install xia -y
  # Marble (avec le moins de dépendance KDE possible)
  apt install --no-install-recommends marble -y
  # OpenMeca
  wget -e use_proxy=yes -e http_proxy=$proxy_params --no-check-certificate http://d.a.d.a.pagesperso-orange.fr/openmeca-64b.deb && dpkg -i openmeca-64b.deb ; apt install -fy ; rm openmeca*
  # BlueGriffon
  wget -e use_proxy=yes -e http_proxy=$proxy_params --no-check-certificate http://bluegriffon.org/freshmeat/3.0.1/bluegriffon-3.0.1.Ubuntu16.04-x86_64.deb && dpkg -i bluegriffon*.deb ; apt install -fy ; rm bluegriffon*
  ### Logiciel non installé (mais existant sous linux) : Xmind (déjà un équivalent), Scenari (pas utile de le pré-installer)
  ./installGeogebra6.sh
  ./installWPS.sh
  ./installVeyon.sh
fi

#=======================================================================================================#
# Installation spécifique suivant l'environnement de bureau

################################
# Concerne Ubuntu / Gnome
################################
if [ "$(which gnome-shell)" = "/usr/bin/gnome-shell" ] ; then  # si GS install
  #[ Paquet AddOns ]
  apt install -y ubuntu-restricted-extras ubuntu-restricted-addons gnome-tweak-tool
  #apt install -y nautilus-image-converter nautilus-script-audio-convert
fi

################################
# Concerne Ubuntu / Unity
################################
if [ "$(which unity)" = "/usr/bin/unity" ] ; then  # si Ubuntu/Unity alors :
  #[ Paquet AddOns ]
  apt-get -y install ubuntu-restricted-extras ubuntu-restricted-addons unity-tweak-tool
  apt-get -y install nautilus-image-converter nautilus-script-audio-convert
fi

################################
# Concerne Xubuntu / XFCE
################################
if [ "$(which xfwm4)" = "/usr/bin/xfwm4" ] ; then # si Xubuntu/Xfce alors :
  #[ Paquet AddOns ]
  apt-get -y install xubuntu-restricted-extras xubuntu-restricted-addons xfce4-goodies xfwm4-themes

  # Customisation XFCE
  if [ "$version" = "trusty" ] || [ "$version" = "xenial" ] ; then #ajout ppa pour 14.04 et 16.04 (pas nécessaire pour la 18.04)
    add-apt-repository -y ppa:docky-core/stable ; apt-get update   
  fi
  apt-get -y install plank ; wget -e use_proxy=yes -e http_proxy=$proxy_params --no-check-certificate https://dane.ac-lyon.fr/spip/IMG/tar/skel_xub1404.tar
  tar xvf skel_xub1404.tar -C /etc ; rm -rf skel_xub1404.tar
fi

################################
# Concerne Ubuntu Mate
################################
if [ "$(which caja)" = "/usr/bin/caja" ] ; then # si Ubuntu Mate 
  apt-get -y install ubuntu-restricted-extras mate-desktop-environment-extras
  apt-get -y purge ubuntu-mate-welcome
fi

################################
# Concerne Lubuntu / LXDE
################################
if [ "$(which pcmanfm)" = "/usr/bin/pcmanfm" ] ; then  # si Lubuntu / Lxde alors :
  apt-get -y install lubuntu-restricted-extras lubuntu-restricted-addons
fi


# Lecture DVD
  if [ "$version" = "trusty" ] ; then #lecture dvd pour 14.04
    apt-get install libdvdread4 -y
    bash /usr/share/doc/libdvdread4/install-css.sh
  fi
  
  if [ "$version" = "xenial" ] || [ "$version" = "bionic" ] || [ "$version" = "focal" ]; then #lecture dvd pour 16.04 ou 18.04
    apt install -y libdvd-pkg
    dpkg-reconfigure libdvd-pkg
  fi

########################################################################
#nettoyage station 
########################################################################
apt-get update ; apt-get -fy install ; apt-get -y autoremove --purge ; apt-get -y clean ;
clear

########################################################################
#FIN
########################################################################
echo "Le script de postinstall a terminé son travail"
