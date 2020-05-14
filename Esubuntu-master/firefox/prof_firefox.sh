#!/bin/sh
#### installation profil firefox eole scribe ####
# - centralisation du profil firefox sur scribe en fonction du groupe
# - verifier si dans usr/lib/firefox/default/pref/channel-pref.js 

# - ver 1.0.2
# - 20 Novembre 2016
# - CALPETARD Olivier - AMI - lycee Antoine ROUSSIN

echo  "installation profil firefox eole scribe"

#les fichiers se trouvent dans icones$ 
#lecture du groupe ESU
gm_esu=grp_eole

if [ -f "/etc/GM_ESU" ];then

gm_esu=$(cat /etc/GM_ESU)
echo "Le PC est dans le groupe esu $gm_esu"
fi

echo '//
lockPref("autoadmin.global_config_url", "file:///tmp/netlogon/icones/'$gm_esu'/linux/firefox.js"); '> /usr/lib/firefox/firefox.cfg


#modification de channel-pref.js si un paramètre est rentré, ne lit pas la config du serveur
echo '//
pref("app.update.channel", "release"); ' > /usr/lib/firefox/defaults/pref/channel-prefs.js 

#dit a firefox qu'il faut charger une config
echo '//
pref("general.config.obscure_value", 0);
pref("general.config.filename", "firefox.cfg"); ' > /etc/firefox/syspref.js 


echo "Configuration terminee."
echo "Le profil firefox est maintenant gere par scribe dans le dossier icones"

echo "\n"
