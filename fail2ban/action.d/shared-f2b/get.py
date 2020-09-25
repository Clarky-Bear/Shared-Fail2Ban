#!/usr/bin/fail2ban-python
import sys
import mysql.connector
import socket

db = mysql.connector.connect(
                        host="127.0.0.1",
                        user="username",
                        passwd="password1",
                        db="f2b")
cur = db.cursor()
host = socket.gethostname()
sql = "SELECT UNIX_TIMESTAMP(created), ip, port, protocol FROM f2b WHERE created>=DATE_ADD(NOW(), INTERVAL -1 HOUR) A$
cur.execute(sql)
row = cur.fetchall()

#print all entries in row and format data
open("/etc/fail2ban/action.d/shared-f2b/filter.log", "w").close()
file = open("/etc/fail2ban/action.d/shared-f2b/filter.log","w")
for x in row:
	file.write("{0} [{1}] {2} {3}".format(*x) + "\n")
file.close()
