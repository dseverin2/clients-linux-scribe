#!/bin/bash


########################################################################
#powered by
########################################################################
fait=$(date +'%d-%m-%Y--%H:%M:%S')

echo "poste installe le : $fait 
" >> /etc/poweredbyme

#Assign existing hostname to $hostn
hostn=$(cat /etc/hostname)

#Display existing hostname
echo "le nom de la machine est $hostn"

#Ask for new hostname $newhost
echo "Entrez le nouveau nom: "
read newhost

#change hostname in /etc/hosts & /etc/hostname
sudo sed -i "s/$hostn/$newhost/g" /etc/hosts
sudo sed -i "s/$hostn/$newhost/g" /etc/hostname

#display new hostname
echo "le nouveau nom est $newhost"

#Press a key to reboot
read -s -n 1 -p "press entrez pour redemarrer"
sudo reboot
