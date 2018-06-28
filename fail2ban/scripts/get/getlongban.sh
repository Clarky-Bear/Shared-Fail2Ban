#!/bin/bash
##Mysql statement, (credetials in file for testing only)
#Statement looks for any recent entries that were added within the last 60 minutes that match the standard SSH jail and originated from any other host other than the statement originator.
#Filter will match if the number of entries matches or exceeds 6

mysql -u fail1 -ppassword -h 172.16.2.10 -e "SELECT UNIX_TIMESTAMP(created), ip, port, protocol FROM fail2ban.fail2ban WHERE created>=DATE_ADD(NOW(), INTERVAL -60 MINUTE) AND hostname != '$host' ORDER BY created ASC;" -N -B > /etc/fail2ban/long.log
