#!/usr/bin/fail2ban-python
# Shared Fail2Ban
# Paul Clark, Adam Boutcher
# github.com/bulgemonkey/Shared-Fail2Ban/

import sys
import datetime
import socket

import shared_cfg as cfg

print (sys.argv[0]) #scritpt name
print (sys.argv[1]) #jailname
print (sys.argv[2]) #protocol
print (sys.argv[3]) #port
print (sys.argv[4]) #ip
print (sys.argv[5]) #bantime

date1 = datetime.datetime.now()

if 'mysql' in cfg.source:
    import mysql.connector
    db = mysql.connector.connect(host=cfg.mysql["host"], user=cfg.mysql["user"], passwd=cfg.mysql["passwd"], db=cfg.mysql["db"])
    cur = db.cursor()
    sql = "INSERT INTO f2b SET hostname=\'" + socket.gethostname() + "\', created=\'" + str(date1) + "\', jail=\'" + sys.argv[1] + "\', protocol=\'" + sys.argv[2] + "\', port=\'" + sys.argv[3] + "\', ip=\'" + sys.argv[4] + "\', bantime=\'" + sys.argv[5] + "\';"
    cur.execute(sql)
    db.commit()
else:
    import json
    import time
    data= {
        "hostname": str(socket.gethostname()),
        "created": int(time.time()),
        "jail": str(sys.argv[1]),
        "protocol": str(sys.argv[2]),
        "port": str(sys.argv[3]),
        "ip": str(sys.argv[4]),
        "bantime": str(sys.argv[5])
    }
    data = json.dumps(data)
    if (sys.version_info > (3, 0)):
        # Python 3 code in this block
        import urllib.request
        req = urllib.request.Request(cfg.apiurl+"/put", data=bytes(data.encode("utf-8")), method='PUT')
        req.add_header("Content-type", "application/json; charset=UTF-8")
        req.add_header("X-TOKEN", cfg.apitoken)
        resp = urllib.request.urlopen(req)
        resp = resp.read().decode('utf-8')
    else:
        # Python 2 code in this block
        import urllib
        import urllib2
        opener = urllib2.build_opener(urllib2.HTTPHandler)
        req = urllib2.Request(cfg.apiurl+"/put", data=bytes(data.encode("utf-8")))
        req.get_method = lambda: 'PUT'
        req.add_header("Content-type", "application/json; charset=UTF-8")
        req.add_header("X-TOKEN", cfg.apitoken)
        resp = opener.open(req)
        resp = resp.read()
    print("API Returned: "+resp)

print ("IP added to database")
