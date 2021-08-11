#!/bin/bash
#Ajoutkav
#Ajout AD


#installation des fonctions de base
#activation licences REDHAT & update
echo -n "Vous allez devoir renseigner les information de compte redhat:   "
subscription-manager register --auto-attach --force
yum update -y 
echo -n "Entrer le nom de votre compte administrateur domaine:   "
read admin

if [[ -n "$admin" ]]
then
        echo -e "Nom du compte $admin "
else
        echo -e  "pas de nom selectionner"
        exit 3;
fi

#Ajout de l'athentification AD 
realm join noz.local -U $admin
sleep 10
rm -f /etc/sssd/sssd.conf
mv /root/sssd.conf /etc/sssd/sssd.conf
/sbin/restorecon -v /etc/sssd/sssd.conf
systemctl restart sssd
echo '%Linux-root-rights@noz.local     ALL=(ALL)   ALL' >> /etc/sudoers

# installation agent KAV 
./AutoInstallation-NetworkAgent_KESL-RPM.sh


#Selection du template d'installation 
PS3='Qu elle template voulez vous utiliser '
template=("Vierge" "php7" "devcenter" "bdd")

select fav in "${template[@]}"; do
        case $fav in
                "Vierge")
                        echo "Le template $fav est déjà prêt"
                        # optionally call a function or run some code here
                        break
                        ;;
                "php7")
                        echo "Le template $fav va être déployé."
                        yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
                        yum -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
                        yum module reset php -y
                        yum install -y @php-7.4
                        yum install -y  php-bz2 php-calendar php-ctype php-curl php-dom php-exif php-fileinfo php-ftp php-gd php-gettext php-iconv php-intl php-ldap php-mbstring php-mysqlnd php-pdo php-phar php-posix php-shmop php-simplexml php-soap php-sockets php-sqlite3 php-sysvmsg php-sysvsem php-sysvshm php-tokenizer php-xml php-xmlwriter php-xsl  php-mysqli php-pdo_mysql  php-pdo_sqlite  php-xmlreader php-json php-zip httpd git php74-php-imap php74-php-mcrypt php74-php-mysql php74-php-pdo_oci php74-php-wddx
                        curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
                        rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg
                        yum install -y yarn
                        yum install -y libxml2 sendmail lftp
                        wget https://getcomposer.org/installer -O composer-installer.php
                        php composer-installer.php --filename=composer --install-dir=/usr/local/bin
                        sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
                        break
                        ;;

                "devcenter")
                        echo "Le template $fav va être déployé."
                        yum update 
                        #Installation docker
                        yum config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
                        yum install docker-ce --nobest -y
                        systemctl start docker
                        systemctl enable docker
                        yum install curl -y
                        #Installation docker compose
                        curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                        chmod +x /usr/local/bin/docker-compose
                        ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
                        docker-compose --version
                        #Installation paquets supplémentaires 
                        yum install python39 git gcc-c++ make -y
                        sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
                        break
                        ;;

                "bdd")
                        echo "Le template $fav va être déployé." 
                        #Installation et activation serveur mariadb 
                        yum -y install mariadb-server     
                        sed -i "s/#bind-address=0.0.0.0/bind-address=0.0.0.0/" /etc/my.cnf.d/mariadb-server.cnf
                        systemctl enable mariadb.service
                        systemctl start mariadb.service
                        sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
                        break
                        ;;

                *) echo "invalid option $REPLY";;
        esac
done


#Gestion droit d'accès au serveur
echo -n "L'accès au serveur est-elle reservé à l'infra o/n ?   "
read access
while [[ "$access" != "o" &&  "$access" != "n" ]];
do
                echo -n "Veuillez choisir [o]ui ou [n]on   "
                read access

done
if [[ "$access" != "o" ]]
        then
                sed -i "s/G-Informatique-linux-auth /G-Informatique-linux-auth-infra/" /etc/sssd/sssd.conf
                echo -n "Les droits ont été appliqués pour le groupe infra "
        else
                echo -n "Les droits ont été appliqués à tous les user linux"
fi

#Changement password root  
echo -n "Vous allez devoir renseigner le nouveau mots de passe root "
passwd 
echo -n "Après avoir vérifier la connection avec un utilisateur AD désactivé la connection ssh avec le root dans /etc/ssh/sshd "


#Ajout utilisateur ansible
useradd ansible-task
echo "ansible-task1   ALL=(ALL)               NOPASSWD:ALL">> /etc/sudoers
echo -n "Vous allez devoir renseigner le nouveau de l'utilisateur ansible-task (keepass): "
passwd ansible-task

#suppression des fichiers d'instalation
rm -f AutoInstallation-NetworkAgent_KESL-RPM.sh autoinst1.sh autoinst2.sh
