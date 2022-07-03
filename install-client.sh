echo "Start installation Icinga2 agent"
echo "install needed packages for installation"
apt install -y apt-transport-https wget gnupg debconf-utils
echo "Add icinga repo and repo key and needed tools voor install"
rm -f /usr/share/keyrings/Icinga.gpg
curl https://packages.icinga.com/icinga.key | gpg --dearmour -o /usr/share/keyrings/Icinga.gpg

. /etc/os-release; if [ ! -z ${UBUNTU_CODENAME+x} ]; then DIST="${UBUNTU_CODENAME}"; else DIST="$(lsb_release -c| awk '{print $2}')"; fi; \
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/Icinga.gpg] https://packages.icinga.com/ubuntu icinga-${DIST} main" > \
/etc/apt/sources.list.d/${DIST}-icinga.list
echo "deb-src [arch=amd64 signed-by=/usr/share/keyrings/Icinga.gpg] https://packages.icinga.com/ubuntu icinga-${DIST} main" >> \
/etc/apt/sources.list.d/${DIST}-icinga.list
apt update
apt install icinga2 monitoring-plugins -y

echo "execute kickstart script you got from gui"
