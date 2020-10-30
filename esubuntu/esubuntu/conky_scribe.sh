#!/bin/bash
#### partie de configuration de conky ####
# - récupère la valeur du groupe et classe pour affiche dans conky sur le bureau 
# - ver 1.0.3
# - 31 Juin 2018
# - CALPETARD Olivier - AMI - lycee Antoine ROUSSIN
# - le fichiers conf de conky se trouve dans icone/postelinux/conky/conky.cfg

#groupe machine
gm_esu=grp_eole
if [ -f "/etc/GM_ESU" ];then

gm_esu=$(cat /etc/GM_ESU)
fi

#groupe et classe utilisateurs
groups $USER > $HOME/gr.txt
tail $HOME/gr.txt | cut -d" " -f4-6 > $HOME/gr_classe.txt
tail $HOME/gr.txt | cut -d" " -f3 > $HOME/gr_scribe.txt
g_esu=$(cat $HOME/gr_scribe.txt)
g_classe=$(cat $HOME/gr_classe.txt)


if [ $g_esu = "eleves" ]
then
sed 's/domainUsers//g' $HOME/gr_classe.txt
echo -e "\t Bureau : $g_esu"
echo -e "\t Groupe : $gm_esu"
else
echo -e "Bureau : $g_esu"
echo -e "\t Groupe : $gm_esu"
fi
exit 0
