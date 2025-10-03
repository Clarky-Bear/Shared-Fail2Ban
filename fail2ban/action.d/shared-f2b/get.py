#!/usr/bin/fail2ban-python
# Shared Fail2Ban
# This is the script that pulls Banned IPs in a given JailName and output it to a file.
# github.com/bulgemonkey/Shared-Fail2Ban/
#
# Paul Clark    - 2018, IPPP, Durham University
#  Initial Database work
# Adam Boutcher - 2020, IPPP, Durham University
#  Inital API work
# Jon Trinder   - 2021, Glasgow University
#  Added arguments to support multiple jailnames (MySQL Untested), default to ssh to keep compatability.

import sys
import json
import argparse
import shared_cfg as cfg

def getjails(jailname):

    if 'mysql' in cfg.source:
        import mysql.connector
        import socket
        db = mysql.connector.connect(
            host=cfg.mysql["host"], user=cfg.mysql["user"], passwd=cfg.mysql["passwd"], db=cfg.mysql["db"])
        cur = db.cursor(dictionary=True)
        host = socket.gethostname()
        sql = "SELECT UNIX_TIMESTAMP(created) as created, ip, port, protocol FROM f2b WHERE created>=DATE_ADD(NOW(), INTERVAL -1 HOUR) AND jail = '%s' AND hostname != '%s'" % (jailname, host)
        cur.execute(sql)
        data = cur.fetchall()
    else:
        if (sys.version_info > (3, 0)):
            # Python 3 code in this block
            import urllib.request
            response = urllib.request.urlopen(cfg.apiurl+"/time/"+jailname+"/1")
        else:
            # Python 2 code in this block
            import urllib
            response = urllib.urlopen(cfg.apiurl+"/time/"+jailname+"/1")
        data = json.loads(response.read())
    logfilename = "/etc/fail2ban/action.d/shared-f2b/filter-"+jailname+".log"

    open(logfilename, "w").close()
    file = open(logfilename, "w")
    for result in data:
        file.write(str(result['created'])+" ["+str(result['ip'])+"] " +
                   str(result['port'])+" "+str(result['protocol'])+"\n")
    file.close()


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('--jail', required=False, help='Enter jailname', dest='jail_name', default="all")
    results = parser.parse_args()
    getjails(results.jail_name)
