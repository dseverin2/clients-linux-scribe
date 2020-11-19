## Scripts pour Client Scribe (x)Ubuntu 14.04, 16.04, 18.04 et 20.04

Ce **script** permet d'intégrer des clients Gnu/Linux dans un environnement Eole-Scribe 2.3, 2.4, 2.5 ou 2.6 

Les clients supportés/testés avec les scripts sont les suivants :
- Ubuntu (Unity) 14.04, 16.04, 18.04 (GS) et 20.04
- Xubuntu (XFCE) 14.04, 16.04, 18.04 et 20.04
- Lubuntu (LXDE) 14.04, 16.04, (Lxde/LxQt) 18.04  et 20.04
- Ubuntu Mate 16.04, 18.04 et 20.04
- Ubuntu Budgie 18.04 et 20.04
- UbuntuDDE 20.04
- Linux Mint (Cinammon/Mate/Xfce) 17.X, 18.X, 19.X et 20.X
- Elementary OS (Pantheon) 0.4, 5.0, 5.1

Ce script d'intégration n'est PAS compatible avec des distributions comme : Debian, Fedora, Solus, Manjaro

  - **IMPORTANT : Modifier le fichier config.cfg** :
	- pensez à créer cet utilisateur dans l'EAD
	- modifier le proxy et les adresses locales (Par défaut le port est 3129)
	- le nom de l'utilisateur et son mot de passe (pour l'authentification wget, apt et snap)
	
  - Se placer dans le répertoire courant puis lancer les commandes :
	
	<code>chmod +x ubuntu-et-variantes-integrdom.sh</code>

	<code>sudo ./ubuntu-et-variantes-integrdom.sh</code>
	
###**Remarques :** 

#### Script de post-installation

Pour gagner du temps lors de la création du poste modèle, on pourra utiliser ensuite le script de post-installation qui installera le système avec toutes les applications souhaitées : https://raw.githubusercontent.com/dane-lyon/clients-linux-scribe/master/ubuntu-et-variantes-postinstall.sh 

#### Partages

Si votre serveur Scribe est en version "2.4" , "2.5" ou "2.6", par défaut vous n'aurez pas les partages avec les clients linux (groupes, classes etc...), pour régler le problème, vous devez faire la manipulation suivante sur votre serveur :
https://dane.ac-lyon.fr/spip/Client-Linux-activer-les-partages

### Problèmes d'identifications possibles 

Pour ne pas avoir de problème d'identification, vérifier que :

- l'utilisateur a déjà changé une fois son mot de passe depuis un poste windows
OU
- le changement de mot de passe n'est pas demandé (case décochée dans l'ead pour l'utilisateur)

### Client Shell

De plus, il est conseillé que la case "client shell linux" soit cochée pour les utilisateurs dans l'EAD du scribe sinon, dans certains cas, l'authentification ne pourra avoir lieu.

#### Personnalisation des menus de l'environnement Unity

Pour personnaliser le menu d'Unity (sur les anciennes versions d'Ubuntu) à tous les utilisateurs, chercher dans le script ces lignes :

	echo "[com.canonical.indicator.session]
	user-show-menu=false
	[org.gnome.desktop.lockdown]
	disable-user-switching=true
	disable-lock-screen=true
	[com.canonical.Unity.Launcher]
	favorites=[ 'nautilus-home.desktop', 'firefox.desktop','libreoffice-startcenter.desktop', 'gcalctool.desktop','gedit.desktop','gnome-screenshot.desktop' ]
	" > /usr/share/glib-2.0/schemas/my-defaults.gschema.override

La ligne
	favorites=[ 'nautilus-home.desktop', 'firefox.desktop','libreoffice-startcenter.desktop','gcalctool.desktop','gedit.desktop','gnome-screenshot.desktop' ]
est à adapter en fonction de vos besoins :

Pour connaitre le nom des raccourcis, faire dans un terminal : ls /usr/share/applications/

Pour voir à quelle application cela correspond, avec l'explorateur, il faut se déplacer dans /usr/share/applications/

Pour appliquer les modifications, il faut lancer la commande :

	<code>sudo glib-compile-schemas /usr/share/glib-2.0/schemas</code>

A noter que chaque élève ou enseignant pourra personnaliser son menu par la suite puisque le profil est local. La personnalisation sera, en revanche, propre à chaque poste.

#### Concernant l'intégration d'un client Linux Mint 19

L'intégration fonctionne mais par défaut l'écran de session LightDM n'est pas modifié pour saisir vous même le login, pour régler le problème c'est très simple : connectez vous avec un compte (compte local ou compte admin ou compte prof) de préférence avant l'intégration au domaine puis il faut aller dans le "centre de contrôle de Cinnamon" (paramètre système) puis en bas dans la section administration "Fenêtre de connexion", dans l'onglet "Utilisateurs", activer "Permettre la connexion manuelle" ainsi que "Cacher la liste des utilisateurs" (éventuellement désactiver aussi "Autoriser les invités à se connecter" si besoin). Si le pavé numérique n'est pas activé au démarrage, vous pouvez en profiter dans "Options" pour activer "Activer le verouillage du pavé numérique" (si l'option est grisé, installer le paquet "numlockx" avant).
Manipulation à faire avant le clonage de vos postes sinon il faudra refaire la manip sur chaque poste...

Enfin, si vous ne savez pas quelle interface de bureau choisir avec Ubuntu, voici un aperçu des différentes variantes supportés :

## Ubuntu 18.04 (Gnome-Shell) :
![Ubuntu 18.04](http://nux87.free.fr/wallpaper_githubdane/ubuntu1804GS.jpg)

## Xubuntu 18.04 (Xfce) :
![Xubuntu 18.04](http://nux87.free.fr/wallpaper_githubdane/xubuntu1804xfce.jpg)

## Lubuntu 18.04 (Lxde) :
![Lubuntu 18.04](http://nux87.free.fr/wallpaper_githubdane/lubuntu1804lxde.jpg)

## Ubuntu Mate 18.04 (Mate) :
![Ubuntu Mate 18.04](http://nux87.free.fr/wallpaper_githubdane/ubuntumate1804.jpg)

## Ubuntu Budgie 18.04 (Budgie) :
![Ubuntu Budgie 18.04](http://nux87.free.fr/wallpaper_githubdane/ubuntubudgie1804.jpg)

## Linux Mint 19 (Cinnamon) :
![Linux Mint 19](http://nux87.free.fr/wallpaper_githubdane/linuxmint19cinnamon.jpg)

## Elementary OS 0.4 (PantheonUI):
![Elementary OS 0.4](http://nux87.free.fr/wallpaper_githubdane/elementaryos04pantheon.jpg)
