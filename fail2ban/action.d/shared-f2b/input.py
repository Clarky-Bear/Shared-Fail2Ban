#!/usr/bin/fail2ban-python
# Shared Fail2Ban
# Paul Clark, Adam Boutcher
# github.com/bulgemonkey/Shared-Fail2Ban/

import sys
import mysql.connector
import datetime
import socket

print sys.argv[0] #scritpt name
print sys.argv[1] #jailename
print sys.argv[2] #protocol
print sys.argv[3] #port
print sys.argv[4] #ip
print sys.argv[5] #bantime

date1 = datetime.datetime.now()

faildb = mysql.connector.connect(
        host='monitoring.dur.scotgrid.ac.uk',
        user='fail1',
        passwd='failure1',
        database='f2b')

con1 = faildb.cursor()
sql = "INSERT INTO f2b SET hostname=\'" + socket.gethostname() + "\', created=\'" + str(date1) + "\', jail=\'" + sys.argv[1] + "\', protocol=\'" + sys.argv[2] + "\', port=\'" + sys.argv[3] + "\', ip=\'" + sys.argv[4] + "\', bantime=\'" + sys.argv[5] + "\';"
con1.execute(sql)
faildb.commit()

print "IP added to database"

