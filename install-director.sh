#!/bin/bash
TMPFILE=/tmp/create.sql

MODULE_NAME=incubator
MODULE_VERSION=v0.17.0
echo "Installing Icingaweb 2 module $MODULE_NAME $MODULE_VERSION"
MODULES_PATH="/usr/share/icingaweb2/modules"
MODULE_PATH="${MODULES_PATH}/${MODULE_NAME}"
RELEASES="https://github.com/Icinga/icingaweb2-module-${MODULE_NAME}/archive"
mkdir "$MODULE_PATH" \
&& wget -q $RELEASES/${MODULE_VERSION}.tar.gz -O - \
   | tar xfz - -C "$MODULE_PATH" --strip-components 1
icingacli module enable "${MODULE_NAME}"

MODULE_NAME=Director
MODULE_VERSION="1.9.1"
echo "Installing Icingaweb 2 module $MODULE_NAME $MODULE_VERSION"
ICINGAWEB_MODULEPATH="/usr/share/icingaweb2/modules"
REPO_URL="https://github.com/icinga/icingaweb2-module-director"
TARGET_DIR="${ICINGAWEB_MODULEPATH}/director"
URL="${REPO_URL}/archive/v${MODULE_VERSION}.tar.gz"

useradd -r -g icingaweb2 -d /var/lib/icingadirector -s /bin/false icingadirector
install -d -o icingadirector -g icingaweb2 -m 0750 /var/lib/icingadirector
install -d -m 0755 "${TARGET_DIR}"
wget -q -O - "$URL" | tar xfz - -C "${TARGET_DIR}" --strip-components 1
cp "${TARGET_DIR}/contrib/systemd/icinga-director.service" /etc/systemd/system/

echo "Create database for $MODULE_NAME"
rm $TMPFILE -f
cat <<<"
DROP DATABASE IF EXISTS \`icinga2_director\`;
create database icinga2_director;
CREATE USER IF NOT EXISTS \`icinga2_director_db\`@\`localhost\`;
ALTER USER \`icinga2_director_db\`@\`localhost\` IDENTIFIED WITH 'caching_sha2_password' BY '$WWDIRECTORDB' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK PASSWORD HISTORY DEFAULT PASSWORD REUSE INTERVAL DEFAULT PASSWORD REQUIRE CURRENT DEFAULT;
GRANT ALL PRIVILEGES ON \`icinga2_director\`.* TO \`icinga2_director_db\`@\`localhost\`;
GRANT USAGE ON *.* TO \`icinga2_director_db\`@\`localhost\`;
FLUSH PRIVILEGES;" >>$TMPFILE
cat $TMPFILE |mysql
rm $TMPFILE -f

icingacli module enable director
systemctl daemon-reload
systemctl enable icinga-director.service
systemctl start icinga-director.service
systemctl restart icinga2

HOSTNAME=`hostname`
echo "Importent setup details save them in safe place!!!!"
echo ""
echo "Database:         icinga2_director user: icinga2_director_db password: $WWDIRECTORDB"
echo "go to http://server-ipadres/icingaweb2 or http://fqdn/icingaweb2 http://$HOSTNAME to complete setup in the Icinga2 gui"



