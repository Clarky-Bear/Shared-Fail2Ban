#!/bin/bash
##Genban.sh, used to retrieve malicous IPs from external database

#Get local hostname
host=$(hostname)
#Mysql statement, (credetials in file for testing only)
# Statement looks for any new entries that were entered in the last 10 minutes that match the standard SSH jail and originated from any other host other than the statement originator. 
mysql -u fail1 -ppassword -h 172.16.2.10 -e "SELECT UNIX_TIMESTAMP(created), ip, port, protocol FROM fail2ban.fail2ban WHERE created>=DATE_ADD(NOW(), INTERVAL -10 MINUTE) AND name = 'SSH' AND hostname != '$host' ORDER BY created ASC;" -N -B > /etc/fail2ban/empty.log
