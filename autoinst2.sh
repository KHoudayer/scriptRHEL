#!/bin/bash
#Ajoutkav
#Ajout AD


yum update -y 
echo -n "Vous allez devoir renseigner les information de compte redhat:   "
subscription-manager register --auto-attach --force

echo -n "Entrer le nom de votre compte administrateur domaine:   "
read admin

if [[ -n "$admin" ]]
then
        echo -e "Nom du compte $admin "
else
        echo -e  "pas de nom selectionner"
        exit 3;
fi


realm join noz.local -U $admin
sleep 10
rm -f /etc/sssd/sssd.conf
mv /root/sssd.conf /etc/sssd/sssd.conf
/sbin/restorecon -v /etc/sssd/sssd.conf
systemctl restart sssd
id houdayer_ke
echo '%Linux-root-rights@noz.local     ALL=(ALL)   ALL' >> /etc/sudoers

./AutoInstallation-NetworkAgent_KESL-RPM.sh
echo -n "Vous allez devoir renseigner le nouveau mots de passe root "
passwd 
echo -n "Après avoir vérifier la connection avec un utilisateur AD désactivé la connection ssh avec le root dans /etc/ssh/sshd "

rm -f AutoInstallation-NetworkAgent_KESL-RPM.sh autoinst1.sh autoinst2.sh



