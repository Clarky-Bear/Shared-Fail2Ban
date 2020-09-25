#!/usr/bin/fail2ban-python
import sys
import json

import shared_cfg as cfg

if 'mysql' in cfg.source:
    import mysql.connector
    import socket
    db = mysql.connector.connect(host=cfg.mysql["host"], user=cfg.mysql["user"], passwd=cfg.mysql["passwd"], db=cfg.mysql["db"])
    cur = db.cursor(dictionary=True)
    host = socket.gethostname()
    sql = "SELECT UNIX_TIMESTAMP(created) as created, ip, port, protocol FROM f2b WHERE created>=DATE_ADD(NOW(), INTERVAL -1 HOUR) AND jail = 'SSH' AND hostname != '%s'" % host
    cur.execute(sql)
    data = cur.fetchall()
else:
    if (sys.version_info > (3, 0)):
        # Python 3 code in this block
        import urllib.request
        response = urllib.request.urlopen(cfg.apiurl)
    else:
        # Python 2 code in this block
        import urllib
        response = urllib.urlopen(cfg.apiurl)
    data = json.loads(response.read())

open("/etc/fail2ban/action.d/shared-f2b/filter.log", "w").close()
file = open("/etc/fail2ban/action.d/shared-f2b/filter.log", "w")
for result in data:
    file.write(str(result['created'])+" ["+str(result['ip'])+"] "+str(result['port'])+" "+str(result['protocol'])+"\n")
file.close()
