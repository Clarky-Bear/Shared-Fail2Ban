#!/bin/bash

##Mysql statement, (credetials in file for testing only)
#Statement looks for any recent entries that were added within the last 720 minutes(12 hours) that match the SSH-LONG jail entries no matter which host was the originator.
#Filter will match if the number of entries matches or exceeds 4
mysql -u fail1 -ppassword -h 172.16.2.10 -e "SELECT UNIX_TIMESTAMP(created), ip, port, protocol FROM fail2ban.fail2ban WHERE created>=DATE_ADD(NOW(), INTERVAL -720 MINUTE) AND name = 'SSH-LONG' ORDER BY created ASC;" -N -B > /etc/fail2ban/verylong.log
