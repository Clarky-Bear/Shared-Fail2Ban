#!/bin/bash
 
#Used by fail2ban to push into database
#Fail2ban action runs script with the following variables:
host=$(hostname) 
jailname=$1
proto=$2
port=$3
ipadd=$4
created=$(date +%y/%m/%d\ %H:%M:%S.00000)
bantime=$5

#These variables are pushed into the external database
commands="INSERT INTO fail2ban SET hostname='$host', created='$created', name='$jailname', protocol='$proto', port='$port', ip='$ipadd', bantime='$5';"


#Mysql statement, (credetials in file for testing only)
echo $commands | /usr/bin/mysql --user=fail1 --password=password -h 172.16.2.10 fail2ban
