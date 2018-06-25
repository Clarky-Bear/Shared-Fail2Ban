 #!/bin/bash

host=$(hostname) 
jailname=$1
proto=$2
port=$3
ipadd=$4
created=$(date +%y/%m/%d\ %H:%M:%S.00000)
bantime=$5

commands="INSERT INTO fail2ban SET hostname='$host', created='$created', name='$jailname', protocol='$proto', port='$port', ip='$ipadd', bantime='$5';"

#echo $commands >> /etc/fail2ban/empty.log
echo $commands | /usr/bin/mysql --user=fail1 --password=password -h 172.16.2.10 fail2ban
