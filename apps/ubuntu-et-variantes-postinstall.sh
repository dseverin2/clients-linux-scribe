#!/bin/bash
# version 2.3 (20/09/20)
# Ce script sert à installer des logiciels supplémentaires utiles pour les collèges & lyçées
# Ce script est utilisable pour Ubuntu et variantes en 14.04, 16.04, 18.04, 20.04

#############################################
# Run using sudo, of course.
#############################################
if [ "$UID" -ne "0" ]; then
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

thislog=/home/$localadmin/basicpostinstall.log
templog=""
if [ "$logfile" != "" ]; then
	templog=$logfile
fi
logfile=$thislog
initlog
	
# Récupération de la version d'ubuntu
getversion

if $installdepuisdomaine; then
	wgetparams="-e use_proxy=yes -e http_proxy=$proxy_params"
else
	wgetparams=""
fi

# désactiver mode intéractif pour automatiser l'installation de wireshark
export DEBIAN_FRONTEND="noninteractive"

writelog "Ajout dépot partenaire"
apt install software-properties-common -y 
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CB2DE8E5

writelog "Vérification que le système est à jour"
apt-get update ; apt-get -y full-upgrade; apt-get -y dist-upgrade

writelog "Installation de gdebi"
apt install gdebi-core -y

writelog "Installation de geany"
apt install geany -y

writelog "Installation d'onlyoffice"
if [ ! -e onlyoffice-desktopeditors_amd64.deb ]; then
	wget $wgetparams --no-check-certificate https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb
fi
dpkg -i onlyoffice-desktopeditors_amd64.deb ; apt-get -fy install ; rm -f onlyoffice-desktopeditors_amd64.deb

writelog "Installation des logiciels de TBI"
chmod +x TBI/*.sh
if $activinspire; then
	writelog "---ActivInspire"
	TBI/installActivInspire.sh
fi
if $ebeam; then
	writelog "---Ebeam"
	TBI/installEbeam.sh
fi

writelog "Installation de Scratux"
chmod +x install*.sh
./installScratux.sh

#########################################
# Paquets uniquement pour Trusty (14.04)
#########################################
if [ "$version" = "trusty" ] ; then
	writelog "INITBLOC" "Trusty 14.04" "---idle, gstreamer, celestia"
	apt-get -y install idle-python3.4 gstreamer0.10-plugins-ugly celestia

	if $LibreOffice; then
		writelog "---Backportage LibreOffice"
		add-apt-repository -y ppa:libreoffice/ppa ; apt-get update ; apt-get -y upgrade
	fi

	writelog "---Google Earth"
	apt-get -y install libfontconfig1:i386 libx11-6:i386 libxrender1:i386 libxext6:i386 libgl1-mesa-glx:i386 libglu1-mesa:i386 libglib2.0-0:i386 libsm6:i386
	if [ ! -e ./google-earth-stable_current_i386.deb ]; then
		wget $wgetparams  https://dl.google.com/dl/earth/client/current/google-earth-stable_current_i386.deb --no-check-certificate; 
	fi
	dpkg -i google-earth-stable_current_i386.deb ; apt-get -fy install
	writelog "ENDBLOC"
fi

#########################################
# Paquets uniquement pour Xenial (16.04)
#########################################
if [ "$version" = "xenial" ] ; then
	if $LibreOffice; then
		writelog "INITBLOC" "Xenial 16.04" "---breeze (Libreoffice), idle, x265"
		apt install -y libreoffice-style-breeze 
		writelog "---Backportage LibreOffice"
		add-apt-repository -y ppa:libreoffice/ppa ; apt update ; apt upgrade -y
	fi
	
	apt-install idle-python3.5 x265 ;

	writelog "---Google Earth"
	if [ ! -e ./google-earth-stable_current_amd64.deb ]; then
		wget $wgetparams --no-check-certificate https://dl.google.com/dl/earth/client/current/google-earth-stable_current_amd64.deb 
	fi
	if [ ! -e ./lsb-core_4.1+Debian13+nmu1_amd64.deb ]; then
		wget $wgetparams --no-check-certificate http://ftp.fr.debian.org/debian/pool/main/l/lsb/lsb-core_4.1+Debian13+nmu1_amd64.deb
	fi
	if [ ! -e ./lsb-security_4.1+Debian13+nmu1_amd64.deb ]; then
		wget $wgetparams --no-check-certificate http://ftp.fr.debian.org/debian/pool/main/l/lsb/lsb-security_4.1+Debian13+nmu1_amd64.deb 
	fi
	dpkg -i lsb*.deb ; dpkg -i google-earth*.deb ; apt install -fy

	writelog "---Celestia"
	wget $wgetparams --no-check-certificate https://gitlab.com/simbd/Scripts_Ubuntu/-/blob/7925144bf30ed4c353b9676521d591dc35c97dde/Celestia_pour_Bionic.sh
	if [ -e Celestia_pour_Bionic.sh ]; then
		echo "Celestia_pour_Bionic.sh récupéré avec succès"
	else
		cp $second_dir/Celestia_pour_Bionic.sh .
	fi
	chmod +x Celestia_pour_Bionic.sh ; ./Celestia_pour_Bionic.sh ; rm Celestia*
	writelog "ENDBLOC"
fi

#########################################
# Paquet uniquement pour Bionic (18.04)
#########################################
if [ "$version" = "bionic" ] ; then
	writelog "INITBLOC" "Bionic 18.04" "---idle, x265"
	apt-get install -y idle-python3.6 x265

	writelog "---Google Earth Pro x64" 
	if [ ! -e ./google-earth-pro-stable_current_amd64.deb ]; then
		wget $wgetparams --no-check-certificate https://dl.google.com/dl/earth/client/current/google-earth-pro-stable_current_amd64.deb ; dpkg -i google-earth-pro-stable_current_amd64.deb ; apt install -fy
	fi
	rm /etc/apt/sources.list.d/google-earth* ; rm google-earth-pro* #dépot google retiré volontairement

	writelog "---Celestia"
	wget $wgetparams --no-check-certificate https://gitlab.com/simbd/Scripts_Ubuntu/-/blob/7925144bf30ed4c353b9676521d591dc35c97dde/Celestia_pour_Bionic.sh
	if [ -e Celestia_pour_Bionic.sh ]; then
		echo "Celestia_pour_Bionic.sh récupéré avec succès sur github"
	else
		cp $second_dir/Celestia_pour_Bionic.sh .
	fi
	chmod +x Celestia_pour_Bionic.sh ; ./Celestia_pour_Bionic.sh ; rm Celestia*

	writelog "---Pilote imprimante openprinting"
	apt-get install -y openprinting-ppds
	writelog "ENDBLOC"
fi

#########################################
# Paquet uniquement pour Focal (20.04)
#########################################
if [ "$version" = "focal" ] ; then
	writelog "INITBLOC" "Focal 20.04" "---idle, x265"
	apt-get install -y idle-python3.6 x265

	writelog "---Google Earth Pro x64" 
	if [ ! -e ./google-earth-pro-stable_current_amd64.deb ]; then
		wget $wgetparams --no-check-certificate https://dl.google.com/dl/earth/client/current/google-earth-pro-stable_current_amd64.deb ; dpkg -i google-earth-pro-stable_current_amd64.deb ; apt install -fy
	fi
	rm /etc/apt/sources.list.d/google-earth* ; rm google-earth-pro* #dépot google retiré volontairement

	writelog "---Celestia"
	if [ -e Celestia_pour_focal.sh ]; then
		echo "Celestia_pour_focal.sh récupéré avec succès sur github"
	else
		cp $second_dir/Celestia_pour_focal.sh .
	fi
	chmod +x Celestia_pour_focal.sh ; ./Celestia_pour_focal.sh ; rm Celestia*

	writelog "---Pilote imprimante openprinting"
	apt-get install -y openprinting-ppds
	
	writelog "ENDBLOC"
fi

#=======================================================================================================#

if [ "$version" != "bionic" ] && [ "$version" != "focal" ] ; then  # Installation spécifique pour 14.04 ou 16.04
	writelog "Drivers imprimantes pour les version < 18.04"
	if [ ! -e ./openprinting-gutenprint_5.2.7-1lsb3.2_amd64.deb ]; then
		wget $wgetparams --no-check-certificate http://www.openprinting.org/download/printdriver/debian/dists/lsb3.2/contrib/binary-amd64/openprinting-gutenprint_5.2.7-1lsb3.2_amd64.deb
	fi
	dpkg -i openprinting-gutenprint_5.2.7-1lsb3.2_amd64.deb ; apt-get -fy install ; rm openprinting-gutenprint*

	writelog "Gdevelop (PPA pas encore actif pour la 18.04)"
	add-apt-repository -y ppa:florian-rival/gdevelop
	apt-get update ; apt-get -y install gdevelop
fi

writelog "drivers pour les scanners les plus courants"
apt-get -y install sane

writelog "Police d'écriture de Microsoft"
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | /usr/bin/debconf-set-selections | apt-get -y install ttf-mscorefonts-installer ;

writelog "Oracle Java 8"
add-apt-repository -y ppa:webupd8team/java ; apt-get update ; echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections | apt-get -y install oracle-java8-installer

writelog "INITBLOC" "[ Bureautique ]"
if $LibreOffice; then
	apt-get -y install libreoffice libreoffice-gtk libreoffice-l10n-fr 
fi
apt-get -y install freeplane scribus gnote xournal cups-pdf okular
writelog "ENDBLOC"

writelog "INITBLOC" "[ Web ]"
apt-get -y install chromium-browser chromium-browser-l10n firefox firefox-locale-fr; 
apt-get -y install adobe-flashplugin ; #permet d'avoir flash en même temps pour firefox et chromium
writelog "ENDBLOC"

writelog "INITBLOC" "[ Video / Audio ]"
apt-get -y install imagination openshot audacity vlc x264 ffmpeg2theora flac vorbis-tools lame oggvideotools mplayer ogmrip goobox
writelog "ENDBLOC"

writelog "INITBLOC" "[ Graphisme / Photo ]"
apt-get -y install blender sweethome3d gimp pinta inkscape gthumb mypaint hugin shutter
writelog "ENDBLOC"

writelog "INITBLOC" "[ Système ]"
apt-get -y install gparted vim pyrenamer rar unrar htop diodon p7zip-full gdebi
writelog "ENDBLOC"

writelog "Wireshark"
debconf-set-selections <<< "wireshark-common/install-setuid true"
apt-get -y install wireshark 
sed -i -e "s/,dialout/,dialout,wireshark/g" /etc/security/group.conf

writelog "INITBLOC" "[ Mathématiques ]"
apt-get -y install algobox carmetal scilab geophar
writelog "ENDBLOC"


writelog "INITBLOC" "[ Sciences ]"
apt-get -y install stellarium avogadro 
writelog "ENDBLOC"


writelog "INITBLOC" "[ Programmation ]"
apt-get -y install ghex geany imagemagick gcolor2
apt-get -y install python3-pil.imagetk python3-pil traceroute python3-tk #python3-sympy
writelog "ENDBLOC"

writelog "INITBLOC" "[ Serveur ]"
apt-get -y install openssh-server openssh-client

writelog "ENDBLOC"


### Supplément de logiciel proposé dans la section wpkg du forum de la dane en version linux (pour Ubuntu 18.04)
### cf : https://forum-dane.ac-lyon.fr/forum/viewforum.php?f=44
if [ "$version" = "bionic" ] || [ "$version" = "focal" ] ; then
	writelog "INITBLOC" "Suppléments de logiciels pour Bionic et Focal"
	writelog "---Openshot-qt, Gshutdown, X-Cas, Planner, extension ooohg, winff, optgeo, ghostscript"
	apt-get -y install openshot-qt gshutdown xcas planner ooohg winff winff-qt optgeo ghostscript #gshutdown équivalent à poweroff
	
	writelog "---GanttProject"
	apt-get -y install openjdk-8-jre oenjdk-11-jre java-11-amazon-corretto-jdk bellsoft-java11-runtime
	if [ ! -e ./ganttproject_2.8.11-r2396-1_all.deb ]; then
		wget $wgetparams --no-check-certificate https://dl.ganttproject.biz/ganttproject-2.8.11/ganttproject_2.8.11-r2396-1_all.deb
	fi
	dpkg -i ganttproject* ; apt install -fy
	
	writelog "---mBlock"
	apt-get -y install libgconf-2-4; 
	if [ ! -e ./mBlock_4.0.4_amd64.deb ]; then
		wget $wgetparams --no-check-certificate http://mblock.makeblock.com/mBlock4.0/mBlock_4.0.4_amd64.deb; 
	fi
	dpkg -i mBlock*.deb ; apt install -fy ;
	
	writelog "---Xia (alias ImageActive)"
	echo "deb http://repository.crdp.ac-versailles.fr/debian xia main" | sudo tee /etc/apt/sources.list.d/xia.list
	wget $wgetparams -q http://repository.crdp.ac-versailles.fr/crdp.gpg -O - | sudo apt-key add -; 
	apt-get update; apt-get install xia -y
	
	writelog "---Marble (avec le moins de dépendance KDE possible)"
	apt install --no-install-recommends marble -y
	
	writelog "---OpenMeca"
	apt-get install libqt5help5 libqt5svg5 libqt5opengl5 libqt5widgets5 libqt5gui5 libqt5xml5 libqt5core5a libboost-all-dev libqwt-qt5-6 libqglviewer2-qt5 -fy
	if [ ! -e ./openmeca-64b.deb ]; then
		wget $wgetparams --no-check-certificate https://openmeca.site/site/dl/openmeca_2.x_amd64.deb
		dpkg -i openmeca*amd64.deb ; apt install -fy
	fi
	
	writelog "---BlueGriffon"
	installfilename=bluegriffon-3.1.Ubuntu18.04-x86_64.deb
	if [ ! -e ./$installfilename ]; then
		wget $wgetparams --no-check-certificate http://bluegriffon.org/freshmeat/3.1/$installfilename && dpkg -i bluegriffon*.deb ; apt install -fy
	fi
	
	writelog "---SCRIPTS SUPPLEMENTAIRES"
	if [ -e $second_dir/installGeogebra6.sh ]; then
		scriptpath=$second_dir/
	elif [ -e ./installGeogebra6.sh ]; then
		scriptpath=./
	else
		scriptpath=""
		writelog "------ SCRIPTS ABSENTS"
	fi
	if [ "$scriptpath" != "" ]; then
		writelog "------Geogebra Classic"
		"$scriptpath"installGeogebra6.sh
		
		# Suites bureautiques
		"$scriptpath"installOffice.sh
		
		
		if $Veyon; then
			writelog "------Veyon"
			"$scriptpath"installVeyon.sh
		fi
		
		writelog "------Openboard"
		"$scriptpath"installOpenBoard.sh $version
	fi
	writelog "ENDBLOC"

	apt --fix-broken install
fi

#=======================================================================================================#
# Installation spécifique suivant l'environnement de bureau

################################
# Concerne Ubuntu / Gnome
################################
if [ "$(which gnome-shell)" = "/usr/bin/gnome-shell" ] ; then  # si GS install
	writelog "[ Paquet AddOns ] de Gnome Shell"
	apt install -y ubuntu-restricted-extras ubuntu-restricted-addons gnome-tweak-tool
	#apt install -y nautilus-image-converter nautilus-script-audio-convert
fi

################################
# Concerne Ubuntu / Unity
################################
if [ "$(which unity)" = "/usr/bin/unity" ] ; then  # si Ubuntu/Unity alors :
	writelog "[ Paquet AddOns ] d\'Unity"
	apt-get -y install ubuntu-restricted-extras ubuntu-restricted-addons unity-tweak-tool
	apt-get -y install nautilus-image-converter nautilus-script-audio-convert
fi

################################
# Concerne Xubuntu / XFCE
################################
if [ "$(which xfwm4)" = "/usr/bin/xfwm4" ] ; then # si Xubuntu/Xfce alors :
	writelog "[ Paquet AddOns ] de XFCE"
	apt-get -y install xubuntu-restricted-extras xubuntu-restricted-addons xfce4-goodies xfwm4-themes

	writelog "Customisation XFCE"
	if [ "$version" = "trusty" ] || [ "$version" = "xenial" ] ; then #ajout ppa pour 14.04 et 16.04 (pas nécessaire pour la 18.04)
		add-apt-repository -y ppa:docky-core/stable ; apt-get update   
	fi
	apt-get -y install plank ; wget $wgetparams --no-check-certificate https://dane.ac-lyon.fr/spip/IMG/tar/skel_xub1404.tar
	tar xvf skel_xub1404.tar -C /etc ; rm -rf skel_xub1404.tar
fi

################################
# Concerne Ubuntu Mate
################################
if [ "$(which caja)" = "/usr/bin/caja" ] ; then # si Ubuntu Mate 
	writelog "Paramétrage de Caja (Ubuntu Mate)"
	apt-get -y install ubuntu-restricted-extras mate-desktop-environment-extras
	apt-get -y purge ubuntu-mate-welcome
fi

################################
# Concerne Lubuntu / LXDE
################################
if [ "$(which pcmanfm)" = "/usr/bin/pcmanfm" ] ; then  # si Lubuntu / Lxde alors :
	writelog "Paramétrage pcmanfm (LXDE)"
	apt-get -y install lubuntu-restricted-extras lubuntu-restricted-addons
fi


writelog "Lecture DVD"
if [ "$version" = "trusty" ] ; then #lecture dvd pour 14.04
	apt-get install libdvdread4 -y
	bash /usr/share/doc/libdvdread4/install-css.sh
fi

if [ "$version" = "xenial" ] || [ "$version" = "bionic" ] || [ "$version" = "focal" ]; then #lecture dvd pour 16.04 ou 18.04
	apt install -y libdvd-pkg
	dpkg-reconfigure libdvd-pkg
fi

writelog "Nettoyage de la station"
apt-get update ; apt-get -fy install ; apt-get -y autoremove --purge ; apt-get -y clean ;
clear

logfile=$templog
writelog "Le script de postinstall a terminé son travail"
