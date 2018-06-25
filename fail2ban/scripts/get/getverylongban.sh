#!/bin/bash

mysql -u fail1 -ppassword -h 172.16.2.10 -e "SELECT UNIX_TIMESTAMP(created), ip, port, protocol FROM fail2ban.fail2ban WHERE created>=DATE_ADD(NOW(), INTERVAL -50000 MINUTE) AND name = 'SSH-LONG' ORDER BY created ASC;" -N -B > /etc/fail2ban/verylong.log
