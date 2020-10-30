## ESUBUNTU

### Présentation du projet Esubuntu

ESUBUNTU a été développé par Olivier Calpetard du lycée Antoine Roussin à La Réunion. 
Il permet :
* de lancer des commandes de manière centralisée (installation d'applications, scripts...)
* d'obtenir des fonds d'écran différents entre élèves et enseignants (admin aura le fond prof)
* de faire redescendre les icones sur les bureau utilisateur en fonction du groupe (eleve prof ou admin)
* d'avoir un panel d'informations en fond : nom du poste, personne connectée, adresse IP, quota... 
* déport de la configuration de Firefox
* Personnalisation du profil utilisateur

![Esubuntu en action](https://framapic.org/c1on2a82srbH/JBfkDgCwhmdZ.png)


### Mise en place d'Esubuntu 

_**RAPPEL : validé/testé pour Ubuntu/Unity en 14.04 et 16.04 ainsi que Ubuntu Mate 16.06/18.04)**_
 avec Ubuntu/Gnome 18.04 les icones du bureau demande une confirmation d'éxécution

#### Mise en place du script

1. Créer un nouveau groupe ESU (via la console ESU) pour vos clients Linux, par exemple "s207"
2. Télécharger le contenu de l'archive et le décompresser 
Lien ici : https://github.com/dane-lyon/Esubuntu/archive/master.zip
3. Copier le dossier "posteslinux" dans R:/icones; contient la configuration de conky et proxy_etab.pac a personnaliser
4. Copier le dossier "linux" dans le dossier du groupe ESU que vous avez créé précédement; il contient la configuration firefox, upkg, gset, message a personnaliser.
5. Copier les fichiers Admin.txt Eleve.txt et Prof.txt dans le dossier du groups ESU créé précédement; contient le chemin du fond d'écran
NB : Le plus rapide est de récupérer directement l'archive ici : https://github.com/dane-lyon/clients-linux-scribe/raw/master/ds_votre_groupe_esu.zip
et de décompresser puis mettre tous le contenu dans votre nouveau groupe esu.
6. Ensuite sur le poste client Ubuntu, Lancer 
recupérer l'archive précécente ou git clone https://github.com/dane-lyon/Esubuntu.git
7. le décompresser et faire un chmod -R +x * du dossier
8. ce positionnner dans le dossier en mode console et lancer "sudo ./install_esubuntu.sh"
9. Le nom du groupe esu sera demandé, il faudra mettre exactement le même nom que le nouveau groupe esu créé précédemment.
pur changer le nom du groupe il faut lancer "sudo ./modifie_groupe_esu.sh"
10. Pour la prise en charge du proxy authentifiant répondre au divers question posées ( ou modifier les valeurs par defaut dans install_proxy_auth.sh) et changer votre valeur proxy par 127.0.0.1:3128 (ci c'est le port que vous avez choisi).
A la première connection sur un pc linux; un script controle la présence d'un fichier cntlm.conf dans "document" utilisateur
si il existe il ne fait rien
sinon un pop-up s'ouvre et demande à l'utilisateur de tapez son mot de passe session
et normalement plus aucune fenêtre d'authentification ne s'afficheras
un raccourcis sur le bureau "depannage_internet" (a copier dans _Machine/Bureau du groupe esu) est là pour relancer la procédure
-trouble possible : mot de passe expiré ou trop long (12 caractère maximun)
et voila c'est fini, redémarrer le poste.


#### Paramétrage de upkg (équivalent de WPKG pour Windows)

Dans le groupe esu linux, il y a un dossier "linux" et dedans un dossier "upkg", à l'intérieur 3 fichiers :
* upkg.txt : ne pas toucher pas à ce fichier sauf si l'on veut complètement désactiver cette fonctionnalité (dans ce cas passez la valeur de 1 à 0).
* script_install.sh : c'est dans ce script qu'on indiquera ce qu'on veut déployer, par exemple si l'on veut mettre à jour tous les postes, il faut mettre ceci :

```bash
          #!/bin/bash
          sudo apt-get update
          sudo apt-get dist-upgrade -y
```
          
Si on veut déployer le logiciel "htop" sur tous les postes :

```bash
          #!/bin/bash
          sudo apt-get install htop -y
```
    
          
Si on veut supprimer le logiciel vlc sur tous les postes :

```bash
          #!/bin/bash
          sudo apt-get remove vlc -y
```
* Le *script upkg* n'est lancé qu'une seule fois sur les postes, pour qu'il soit de nouveau lancé (par exemple si on a fait 
des changements dans le script), on doit modifier le fichier "stamp.date", en effet ce fichier est comparé à chaque fois 
avec celui présent en local sur les machines, si il y a une différence, alors le script est lancé et le fichier local maj 
à l'identique sinon rien n'est lancé. 
* Par défaut, la période de rafraîchissement pour la vérification est de *20 minutes* donc on peut attendre jusqu’à 20 minutes 
maximum avant d'avoir le script de lancé sur les postes clients. Si on veut modifier cette durée, c'est dans le fichier 
/etc/crontab.

A noté que depuis votre client linux, vous pouvez directement accéder/modifier les fichiers de votre groupe esu linux (à condition d'avoir biensûr redémarré le poste après l'intégration au domaine) en accédant au répertoire suivant :
/tmp/netlogon/icones/{nom de votre groupe esu linux}/


### Paramétrages complémentaires

* Il est possible de personnaliser le panel conky en allant dans son icones/posteslinux puis "conky" et enfin fichier "conky.cfg"

Par exemple, si l'adresse IP du poste ne s'affichage pas dans conky, c'est probablement parceque l'interface réseau de vos postes n'a pas le mme nom que celle indiqué dans conky dans ce cas il vous suffit de regarder (via la commande "ifconfig") le nom de votre interface réseau et de remplacer dans le fichier conky.cfg "${addr eth0}" par "${addr VotreInterface}"

* La config de Firefox est déporté aussi dans le groupe_esu. Il est ainsi possible de modifier la page d’accueil et le proxy de tous les postes du groupe esu d'un seul coup, pour cela il faut modifier le fichier "firefox.js" dans le dossier "linux" du groupe esu.
_Attention : le proxy est géré aussi par ce fichier, par défaut il est paramétré sur 172.16.0.252, si l'on a autre chose, bien penser à modifier la valeur._ 

spécificité pour proxy authantifiant ac-reunion vers metice : modifier les valeurs du proxy dans posteslinux/proxy_etab.pac

* Personnalisation de l'interface utilisateur:
Dans le dossier linux/gset se trouve un fichiers gset.sh qui est executé a chaque ouverture de session
modifier ou ajouter avec précaution vos régle de personnalisation (par exemple modifier le théme par defaut ou afficher l'heure ou executer une commande particulière etc.....).

* Dernière précision : si vous avez un Scribe en version 2.4, 2.5 ou 2.6, pensez à faire ceci pour avoir les partages réseaux :
https://dane.ac-lyon.fr/spip/Client-Linux-activer-les-partages


