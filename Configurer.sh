#!/bin/bash
sudo apt install yad -y
thisrep=$(cd $( dirname ${BASH_SOURCE[0]}) && pwd )
conf="$thisrep/config.cfg"
source "$conf"

retour=$(yad --title="Paramétrage Domaine 1/3" --form\
 --field="Installation Depuis Domaine":CHK\
 --field="IP Scribe":CBE\
 --field="APT Username":CBE\
 --field="APT Password":H\
 --field="Proxy Authentifiant":CHK\
 --field="IP Proxy":CBE\
 --field="Port Proxy (défaut)":CBE\
 --field="Port Proxy (alt)":CBE\
 --field="No Proxy Gnome":CBE\
 --field="No Proxy Env":CBE\
 -- "$installdepuisdomaine" "$scribe_def_ip" "$scribeuserapt" "$scribepass" "$proxauth" "$proxy_def_ip" "$proxy_def_port" "$proxy_alt_port" "$proxy_gnome_noproxy" "$proxy_env_noproxy")
echo "$retour"

dom=$(echo $retour | awk 'BEGIN {FS="|" } { print $1 }')
if [ "$dom" != "" ]; then sed -i -e "s/^installdepuisdomaine=.*/installdepuisdomaine=$dom/g" "$conf" ;fi
ipscr=$(echo $retour | awk 'BEGIN {FS="|" } { print $2 }')
if [ "$ipscr" != "" ]; then sed -i -e "s/^scribe_def_ip=.*/scribe_def_ip=\"$ipscr\"/g" "$conf"; fi
aptusr=$(echo $retour | awk 'BEGIN {FS="|" } { print $3 }')
if [ "$aptusr" != "" ]; then sed -i -e "s/^scribeuserapt=.*/scribeuserapt=\"$aptusr\"/g" "$conf"; fi
aptpass=$(echo $retour | awk 'BEGIN {FS="|" } { print $4 }')
if [ "$aptpass" != "" ]; then sed -i -e "s/^scribepass=.*/scribepass=\"$aptpass\"/g" "$conf"; fi
proxau=$(echo $retour | awk 'BEGIN {FS="|" } { print $5 }')
if [ "$proxau" != "" ]; then sed -i -e "s/^proxauth=.*/proxauth=$proxau/g" "$conf"; fi
ipprox=$(echo $retour | awk 'BEGIN {FS="|" } { print $6 }')
if [ "$ipprox" != "" ]; then sed -i -e "s/^proxy_def_ip=.*/proxy_def_ip=\"$ipprox\"/g" "$conf"; fi
portprox=$(echo $retour | awk 'BEGIN {FS="|" } { print $7 }')
if [ "$portprox" != "" ]; then sed -i -e "s/^proxy_def_port=.*/proxy_def_port=\"$portprox\"/g" "$conf"; fi
portprox2=$(echo $retour | awk 'BEGIN {FS="|" } { print $8 }')
if [ "$portprox2" != "" ]; then sed -i -e "s/^proxy_alt_port=.*/proxy_alt_port=\"$portprox2\"/g" "$conf"; fi
noproxgn=$(echo $retour | awk 'BEGIN {FS="|" } { print $9 }'| sed 's/\//\\\//g')
if [ "$noproxgn" != "" ]; then sed -i -e "s/^proxy_gnome_noproxy=.*/proxy_gnome_noproxy=\"$noproxgn\"/g" "$conf"; fi
noproxen=$(echo $retour | awk 'BEGIN {FS="|" } { print $10 }' | sed 's/\//\\\//g')
if [ "$noproxen" != "" ]; then sed -i -e "s/^proxy_env_noproxy=.*/proxy_env_noproxy=\"$noproxen\"/g" "$conf"; fi

retour=$(yad --title="Paramétrage Esubuntu 2/3" --form\
 --field="Esubuntu":CHK\
 --field="Nom Etablissement":CBE\
 --field="Port CNTLM":CBE\
 --field="Type CNTLM":CBE\
 --field="Nom Domaine":CBE\
 --field="SOS Problème info":CBE\
 --field="Salle":CBE\
 --field="RNE":CBE\
 -- "$esubuntu" "$nom_etab" "$port_cntlm" "$type_cntlm" "$nom_domaine" "$sos_info" "$salle" "$rne_etab")
echo "$retour"


esu=$(echo $retour | awk 'BEGIN {FS="|" } { print $1 }')
if [ "$esu" != "" ]; then sed -i -e "s/^esubuntu=.*/esubuntu=$esu/g" "$conf"; fi
etab=$(echo $retour | awk 'BEGIN {FS="|" } { print $2 }')
if [ "$etab" != "" ]; then sed -i -e "s/^nom_etab=.*/nom_etab=\"$etab\"/g" "$conf"; fi
pcntlm=$(echo $retour | awk 'BEGIN {FS="|" } { print $3 }')
if [ "$pcntlm" != "" ]; then sed -i -e "s/^port_cntlm=.*/port_cntlm=\"$pcntlm\"/g" "$conf"; fi
tcntlm=$(echo $retour | awk 'BEGIN {FS="|" } { print $4 }')
if [ "$tcntlm" != "" ]; then sed -i -e "s/^type_cntlm=.*/type_cntlm=\"$tcntlm\"/g" "$conf"; fi
ndom=$(echo $retour | awk 'BEGIN {FS="|" } { print $5 }' | sed 's/\//\\\//g')
if [ "$ndom" != "" ]; then sed -i -e "s/^nom_domaine=.*/nom_domaine=\"$ndom\"/g" "$conf"; fi
sos=$(echo $retour | awk 'BEGIN {FS="|" } { print $6 }' | sed 's/\//\\\//g')
if [ "$sos" != "" ]; then sed -i -e "s/^sos_info=.*/sos_info=\"$sos\"/g" "$conf"; fi
lieu=$(echo $retour | awk 'BEGIN {FS="|" } { print $7 }')
if [ "$lieu" != "" ]; then sed -i -e "s/^salle=.*/salle=\"$lieu\"/g" "$conf"; fi
rne=$(echo $retour | awk 'BEGIN {FS="|" } { print $8 }')
if [ "$rne" != "" ]; then sed -i -e "s/^rne_etab=.*/rne_etab=\"$rne\"/g" "$conf"; fi


retour=$(yad --title="Paramétrage Applications 3/3" --form\
 --field="Page d'accueil de Firefox":CBE\
 --field="Heure d'extinction auto":CBE\
 --field="Installer logiciels de base":CHK\
 --field="Installer logiciels avancés":CHK\
 --field="Installer ANSIBLE":CHK\
 --field="Configurer pĥotocopieur":CHK\
 --field="Installer eBeam":CHK\
 --field="Installer activInspire":CHK\
 --field="Installer WPSOffice":CHK\
 --field="Installer LibreOffice":CHK\
 --field="Installer OpenOffice":CHK\
 --field="Installer Veyon":CHK\
 --field="Redémarrer à la fin":CHK\
 -- "$pagedemarragepardefaut" "$extinction" "$postinstallbase" "$postinstalladditionnel" "$ansible" "$config_photocopieuse" "$ebeam" "$activinspire" "$WPSOffice" "$LibreOffice" "$OpenOffice" "$Veyon" "$reboot")
echo "$retour"

accueil=$(echo $retour | awk 'BEGIN {FS="|" } { print $1 }' | sed 's/\//\\\//g')
if [ "$accueil" != "" ]; then sed -i -e "s/^pagedemarragepardefaut=.*/pagedemarragepardefaut=\"$accueil\"/g" "$conf"; fi
shutd=$(echo $retour | awk 'BEGIN {FS="|" } { print $2 }')
if [ "$shutd" != "" ]; then sed -i -e "s/^extinction=.*/extinction=\"$shutd\"/g" "$conf"; fi
base=$(echo $retour | awk 'BEGIN {FS="|" } { print $3 }')
if [ "$base" != "" ]; then sed -i -e "s/^postinstallbase=.*/postinstallbase=$base/g" "$conf"; fi
add=$(echo $retour | awk 'BEGIN {FS="|" } { print $4 }')
if [ "$add" != "" ]; then sed -i -e "s/^postinstalladditionnel=.*/postinstalladditionnel=$add/g" "$conf"; fi
ansi=$(echo $retour | awk 'BEGIN {FS="|" } { print $5 }')
if [ "$ansi" != "" ]; then sed -i -e "s/^ansible=.*/ansible=$ansi/g" "$conf"; fi
copieur=$(echo $retour | awk 'BEGIN {FS="|" } { print $6 }')
if [ "$copieur" != "" ]; then sed -i -e "s/^config_photocopieuse=.*/config_photocopieuse=$copieur/g" "$conf"; fi
ebe=$(echo $retour | awk 'BEGIN {FS="|" } { print $7 }')
if [ "$ebe" != "" ]; then sed -i -e "s/^ebeam=.*/ebeam=$ebe/g" "$conf"; fi
prom=$(echo $retour | awk 'BEGIN {FS="|" } { print $8 }')
if [ "$prom" != "" ]; then sed -i -e "s/^activinspire=.*/activinspire=$prom/g" "$conf"; fi
wps=$(echo $retour | awk 'BEGIN {FS="|" } { print $9 }')
if [ "$wps" != "" ]; then sed -i -e "s/^WPSOffice=.*/WPSOffice=$wps/g" "$conf"; fi
libre=$(echo $retour | awk 'BEGIN {FS="|" } { print $10 }')
if [ "$libre" != "" ]; then sed -i -e "s/^LibreOffice=.*/LibreOffice=$libre/g" "$conf"; fi
open=$(echo $retour | awk 'BEGIN {FS="|" } { print $11 }')
if [ "$open" != "" ]; then sed -i -e "s/^OpenOffice=.*/OpenOffice=$open/g" "$conf"; fi
vey=$(echo $retour | awk 'BEGIN {FS="|" } { print $12 }')
if [ "$vey" != "" ]; then sed -i -e "s/^Veyon=.*/Veyon=$vey/g" "$conf"; fi
reb=$(echo $retour | awk 'BEGIN {FS="|" } { print $13 }')
if [ "$reb" != "" ]; then sed -i -e "s/^reboot=.*/reboot=$reb/g" "$conf"; fi

sed -i -e "s/TRUE/true/g" "$conf"
sed -i -e "s/FALSE/false/g" "$conf"
source "$conf"
