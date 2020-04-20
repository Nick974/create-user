# create-user.sh
Script bash de création d’utilisateurs Linux à partir d’un fichier CSV.

# Contexte
Ce script a été testé et utilisé sur une « machine » Raspberry Pi 3 sous Raspbian GNU/Linux 9.4 (stretch).  
Il était entre autres destiné à la création de comptes FTP pour des élèves qui suivent la spécialité NSI.  
Les utilisateurs créés sont affectés à un groupe supposé existant : webnsi

# Utilisation
bash create-user.sh [FILE]

En l'absence de \<FILE>, le nom d'utilisateur et le mot de passe seront à saisir.  
Le fichier \<FILE> doit contenir des lignes au format \<user>;\<passwd>  
Les mots de passe sont clair -> fichier à ne pas laisser traîner ;)  
