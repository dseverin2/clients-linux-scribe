#!/bin/bash
sudo apt-get remove --purge libreoffice* openoffice* -y
sudo apt-get clean -y
sudo apt-get autoremove -y
#Open Office
OOinstallfile="Apache_OpenOffice_4.1.7_Linux_x86-64_install-deb_fr.tar.gz"

# Extension CMaths OOo
CMinstallfile="CmathOOo.oxt"

# Extension TexMaths
TMversion="0.48.2"
TMinstallfile="TexMaths-"$TMversion".oxt"

if [ ! -e $OOinstallfile ]; then
	wget https://liquidtelecom.dl.sourceforge.net/project/openofficeorg.mirror/4.1.7/binaries/fr/$OOinstallfile
fi
tar xvf $OOinstallfile
dpkg -i ./fr/DEBS/*.deb ./fr/DEBS/desktop-integration/*.deb
if [ ! -e $CMinstallfile ]; then
	wget http://cdeval.free.fr/CmathOOoUpdate/$CMinstallfile
fi
if [ ! -e $TMinstallfile ]; then
	wget https://liquidtelecom.dl.sourceforge.net/project/texmaths/$TMversion/$TMinstallfile
fi
unopkg add --shared CmathOOo.oxt TexMaths*.oxt
wget http://cdeval.free.fr/IMG/ttf/Cmath.ttf -P /usr/share/fonts
wget http://cdeval.free.fr/IMG/ttf/cmathscr.ttf -P /usr/share/fonts
wget http://cdeval.free.fr/IMG/ttf/cmathcal.ttf -P /usr/share/fonts
chmod a+r /usr/share/fonts/*
fc-cache -f -v
rm -fr *.oxt fr/ $OOinstallfile
