#!/bin/bash

#### personnalisation environnement session ubuntu ####
# - executer a chaque ouverture de session
# - gestion des restriction gsetting
# - ver 2.0.1
# - 3 mai 2018
# - CALPETARD Olivier
gsettings set  org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
gsettings set org.gnome.system.proxy mode 'manual'
gsettings set org.gnome.system.proxy.http host '127.0.0.1'
gsettings set org.gnome.system.proxy.http port 3128
gsettings set org.gnome.system.proxy.https host '127.0.0.1'
gsettings set org.gnome.system.proxy.https port 3128
gsettings set org.gnome.system.proxy.ftp host '127.0.0.1'
gsettings set org.gnome.system.proxy.ftp port 3128
gsettings set org.gnome.system.proxy.socks host '127.0.0.1'
gsettings set org.gnome.system.proxy.socks port 3128
gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.1/8', '172.18.40.0/21', '10.210.9.10', '10.210.9.67']"
gsettings set org.gnome.desktop.lockdown disable-lock-screen 'false'
gsettings set org.gnome.desktop.session idle-delay 0
#gsettings set org.gnome.settings-daemon.plugins.print-notifications active false
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.interface clock-show-seconds true
gsettings set org.gnome.nautilus.icon-view default-zoom-level 'small'
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position LEFT
#gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode FIXED
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 32
gsettings set org.gnome.shell.extensions.dash-to-dock unity-backlit-items true



