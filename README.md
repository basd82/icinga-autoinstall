# icinga-autoinstall
Auto install scripts for icinga on ubuntu

The script is designed for new server not running any other services. 
So it ignores any current settings /databases it wil overwrite them

Use is at own risc
Script is without warenty

## ussage main install script

run this command and installation process will start:
```
curl https://raw.githubusercontent.com/basd82/icinga-autoinstall/main/install-icinga2.sh -o install-icinga2.sh;bash install-icinga2.sh;rm install-icinga2.sh
```
script wil ends with information so you complete the setup with gui in the webinterface:
Safe this in a safe place it wil only display once:
```
Importent setup details save them in safe place!!!!

Database:         icinga_ido user: icinga_ido_db password: Secretstuff
Database:         icinga_ido user: icinga_ido_db password: Secretstuff
Setup token:      Secretstuff
API user:         root
API password:     Secretstuff

go to http://server-ipadres/icingaweb2/setup or http://fqdn/icingaweb2/setup http://some.domain.tld to complete setup
```

## ussage director install script
The script install director and incubator modules, the incubator module is required by director.
The script also wil create the required database for the director..
run this command and installation process will start:
```
curl https://raw.githubusercontent.com/basd82/icinga-autoinstall/main/install-director.sh -o install-director.sh;bash install-director.sh;rm install-director.sh
```
script wil ends with information so you complete the setup with gui in the webinterface:
Safe this in a safe place it wil only display once:
```
Importent setup details save them in safe place!!!!

Database:         icinga2_director user: icinga2_director_db password:
go to http://server-ipadres/icingaweb2 or http://fqdn/icingaweb2 http://some.domain.tld to complete setup in the Icinga2 gui
```
## ussage Client install script
the is installs icinga2 agent/client, after install you need to run the agent deploy script

run this command and installation process will start:
```
curl https://raw.githubusercontent.com/basd82/icinga-autoinstall/main/install-client.sh -o install-client.sh;bash install-client.sh;rm install-client.sh
```


# Security Advice
* It is advised to setup the web server so that https is mandatory. So that all traffic to the web interface is encrypted
* It adivsed to set an root password for mysql

#### resources used 

* U used the documentation Icinga [^1][^2][^3][^4] but adjusted it to my situation to get it working.
* I use the php repo [^5] of Ondřej Surý [^6] for the php 8.0 on ubuntu 22.04

[^1]: https://icinga.com/docs/icinga-2/latest/
[^2]: https://icinga.com/docs/icinga-web/latest/
[^3]: https://icinga.com/docs/icinga-2/latest/
[^4]: https://icinga.com/docs/icinga-director/latest/
[^5]: https://launchpad.net/~ondrej/+archive/ubuntu/php
[^6]: https://launchpad.net/~ondrej
