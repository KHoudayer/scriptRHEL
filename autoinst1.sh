#!/bin/bash
#Changement d'hostname
#Changement d'ip

echo -n "Entrer le nom du serveur:   "
read hostname

if [[ -n "$hostname" ]]
then
        echo -e "Nom de machine $hostname saisi"
else
        echo -e  "pas de nom selectionner"
        exit 3;
fi

rm  /etc/hostname
echo "$hostname.noz.local" >> /etc/hostname


echo -n "Entrer l'ip du serveur voulu':   "
read ipadd
if [[ -n "$ipadd" ]]
then
        echo -e "l'ip : $ipadd est saisi"
else
        echo -e  "pas d'ip selectionner"
        exit 3;
fi


sed -i "s/172.31.101.106/$ipadd/" /etc/sysconfig/network-scripts/ifcfg-ens192


echo -n "le serveur va rebooter dans 10 sec faites ctrl + c pour annuler"
sleep 10
reboot

