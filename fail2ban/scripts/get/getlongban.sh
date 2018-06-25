#!/bin/bash

mysql -u fail1 -ppassword -h 172.16.2.10 -e "SELECT UNIX_TIMESTAMP(created), ip, port, protocol FROM fail2ban.fail2ban WHERE created>=DATE_ADD(NOW(), INTERVAL -60 MINUTE) AND hostname != '$host' ORDER BY created ASC;" -N -B > /etc/fail2ban/long.log
