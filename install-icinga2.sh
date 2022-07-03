#!/bin/bash

USERINODB ='icinga_ido_db'
USERWEBDB ='icingaweb_db'
WWIDODB=`</dev/urandom tr -dc 'A-Za-z0-9*_+=' | head -c32`
WWICINGAWEB=`</dev/urandom tr -dc 'A-Za-z0-9*_+=' | head -c32`
TMPFILE=/tmp/create.sql

echo "Add ondrej/php repostory"
add-apt-repository ppa:ondrej/php -y
echo "Add icinga repo and repo key and needed tools voor install"
apt-get update
apt-get -y install apt-transport-https wget gnupg debconf-utils
rm -f /usr/share/keyrings/Icinga.gpg
curl https://packages.icinga.com/icinga.key | gpg --dearmour -o /usr/share/keyrings/Icinga.gpg

. /etc/os-release; if [ ! -z ${UBUNTU_CODENAME+x} ]; then DIST="${UBUNTU_CODENAME}"; else DIST="$(lsb_release -c| awk '{print $2}')"; fi; \
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/Icinga.gpg] https://packages.icinga.com/ubuntu icinga-${DIST} main" > \
/etc/apt/sources.list.d/${DIST}-icinga.list
echo "deb-src [arch=amd64 signed-by=/usr/share/keyrings/Icinga.gpg] https://packages.icinga.com/ubuntu icinga-${DIST} main" >> \
/etc/apt/sources.list.d/${DIST}-icinga.list

echo "Install apache2, mariadb server, php 8.0, icinga2 and monitoring-plugins icinga2-ido-mysql"
echo "icinga2-ido-mysql       icinga2-ido-mysql/enable        boolean true"| debconf-set-selections
echo "icinga2-ido-mysql icinga2-ido-mysql/dbconfig-install boolean false"| debconf-set-selections
apt install apache2 mariadb-server mariadb-client mariadb-common php8.0 php8.0-gd php8.0-mbstring php8.0-mysqlnd php8.0-curl php8.0-xml php8.0-cli php8.0-soap php8.0-intl php8.0-xmlrpc php8.0-zip  php8.0-common php8.0-opcache php8.0-gmp php8.0-imagick php8.0-pgsql icinga2 monitoring-plugins icinga2-ido-mysql -y

rm $TMPFILE -f
cat <<<"
DROP DATABASE IF EXISTS \`icinga_ido\`;
DROP DATABASE IF EXISTS \`icingaweb\`;
create database icinga_ido;
create database icingaweb;
GRANT ALL ON icinga_ido.* TO '$USERINODB'@'localhost' IDENTIFIED BY '$WWIDODB';
GRANT ALL ON icingaweb.* TO '$USERWEBDB'@'localhost' IDENTIFIED BY '$WWWEBDB';
FLUSH PRIVILEGES;" >>$TMPFILE
cat $TMPFILE |mysql

echo "Installing Icinga2 and Monitoring Plugins"
apt install icinga2 monitoring-plugins -y

echo "icinga2-ido-mysql       icinga2-ido-mysql/enable        boolean true"| debconf-set-selections
echo "icinga2-ido-mysql icinga2-ido-mysql/dbconfig-install boolean false"| debconf-set-selections
apt install icinga2-ido-mysql -y
echo "Setup incinga2-ido database"
mysql -u root icinga_ido < /usr/share/icinga2-ido-mysql/schema/mysql.sql
echo "Create  icinga_ido database config file"
cat <<<"
/**
 * The db_ido_mysql library implements IDO functionality
 * for MySQL.
 */

library \"db_ido_mysql\"

object IdoMysqlConnection \"ido-mysql\" {
  user = \"icinga_ido_db\",
  password = \"$WWIDODB\",
  host = \"localhost\",
  database = \"icinga_ido\"
}" >/etc/icinga2/features-available/ido-mysql.conf
echo "Enable ido-mysql feature Icinga"
icinga2 feature enable ido-mysql
echo "Restart Icinga"
systemctl restart icinga2
echo "Install Icingaweb2"
apt install icingaweb2 icingacli -y
echo "Create setup token "
SETUPTOKEN=`icingacli setup token create | cut  -d' ' -f 7`
echo "Create api key"
icinga2 api setup
APIUSER=`cat /etc/icinga2/conf.d/api-users.conf  |grep 'object ApiUser' |cut -d'"' -f 2`
APIWW=`cat /etc/icinga2/conf.d/api-users.conf  |grep 'password' |cut -d'"' -f 2`
echo "restarting Icinga 2 daemon"
systemctl restart icinga2
echo "showing icinga2 service status"
systemctl status icinga2
echo "removing tempfile"
rm $TMPFILE -f

HOSTNAME=`hostname`
echo "Importent setup details save them in safe place!!!!"
echo ""
echo "Database:         icinga_ido user: $USERINODB password: $WWIDODB"
echo "Database:         icingaweb user: $USERWEBDB password: $WWICINGAWEB"
echo "Setup token:      $SETUPTOKEN"
echo "API user:         $APIUSER"
echo "API password:     $APIWW"
echo "";
echo "go to http://server-ipadres/icingaweb2/setup or http://fqdn/icingaweb2/setup http://$HOSTNAME to complete setup"
