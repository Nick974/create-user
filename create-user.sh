#!/bin/bash

#***********************************************#
#               create-user.sh                  #
#      N. Defaÿ, v3.2 du 20 Avr. 2020           #
#                                               #
#  Création automatisée de comptes Linux.       #
#                                               #
# USAGE:                                        #
#   create-user.sh [FILE]                       #
#                                               #
# TODO:                                         #
#   - Gestion des ";" dans le mot de passe      # 
#   - Ajouter option pour mode non verbeux      #
#***********************************************#

if [ $EUID -ne 0 ]; then
  echo "Ce script doit être lancé avec les privilèges root."
  exit 1
fi

script_dir=$(dirname $0)	# Dossier du script
www_dir=/var/www/html		# Base des "home" des utilisateurs

# Affichage de l'entête le cas échéant 
if [ -f "$script_dir/$0.txt" ]; then
  cat $script_dir/$0.txt
fi

# ----------------------------------------------------------- #
# readUser()                                                  #
# Saisie du login et du mot de passe de l'utilisateur à créer #
# Var glob. : $user $pwd1 $pw2                                #
# Retourne  : 0 en cas de succès, 1 sinon.                    #
# ----------------------------------------------------------- #
readUser()
{
	read -p "Nom d'utilisateur : " user
	if [ "$user" == "" ]; then 
		echo "Utilisateur non créé !"
		return 1
	fi
	
	read -sp "Mot de passe : " pwd1
	echo
	read -sp "Confirmer le mot de passe : " pwd2
	echo ""

	if [ $pwd1 != $pwd2 ]
	then
		echo -e "\nLes deux mots de passe sont différents ou vides !"
		echo "Utilisateur non créé !"
		return 1
	else
		return 0
	fi
}

# ----------------------------------------------------------- #
# createLinuxUser()                                           #
# Création de l'utilisateur et redirection du dossier ~       #
# Le groupe webnsi est supposé existant                       #
# Paramètres : $user $passwd                                  #
# ----------------------------------------------------------- #
createLinuxUser()
{
	echo "--------------------------------------"
	echo "...Création du compte Linux :" $1
	sleep 1
	
	useradd -d $www_dir/$1 -g webnsi -m -s /bin/false $1
	if [ $? == 0 ]; then
		chpasswd <<< $1:$2	# pas de mkpasswd ?!

		# Fichiers inutiles : SSH non autorisé ici
		rm $www_dir/$1/.bash_logout
		rm $www_dir/$1/.bashrc
		rm $www_dir/$1/.profile

		echo "Compte Linux créé"
	else
		echo "Compte Linux non créé"
	fi
}

# ----------------------------------------------------------- #
# createLinuxUserFromFile()                                   #
# Création d'utilisateurs en lot                              #
# Paramètre : $filename       (format <user>;<passwd>)        #
# ----------------------------------------------------------- #
createLinuxUserFromFile()
{
	if [ -f "$1" ]
	then
		# Suppression du codage de fin ligne ^M (Windows)
		sed -i 's/\r$//g' $1
	
		for user in `cat $1`
		do
			name=`echo $user | cut -d';' -f1`
			pwd=`echo $user | cut -d';' -f2`
			createLinuxUser $name $pwd
		done
	else
		echo "Fichier $1 introuvable !"
	fi
}

# ----------------------------------------------------------- #

if [ "$1" == "" ]
then
	# Absence de fichier en argument
	readUser
	if [ $? == 0 ]; then
		createLinuxUser $user $pwd1
	fi
else 
	echo "Création de comptes à partir du fichier $1"
	createLinuxUserFromFile $1
fi
