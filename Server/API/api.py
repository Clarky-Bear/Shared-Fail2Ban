#!/usr/bin/python3

import socket
import datetime
from flask import Flask
from flask import jsonify
from flask import request
from flask import escape
from flask_caching import Cache
import mysql.connector

import api_cfg as cfg

app = Flask(__name__)
app.url_map.strict_slashes = False
cache = Cache(config={'CACHE_TYPE': 'simple'})
cache.init_app(app)

@app.route('/', methods=['GET'])
@app.route('/api', methods=['GET'])
@app.route('/api/', methods=['GET'])
@cache.cached(timeout=3600)
def about():
    return '<h3>Shared Fail2Ban API</h3><br/><strong>Paul Clark, Adam Boutcher</strong><br/>(<em>UKI-SCOTGRID-DURHAM</em>) IPPP, Durham University.<br/><br/><a href="https://github.com/bulgemonkey/Shared-Fail2Ban">https://github.com/bulgemonkey/Shared-Fail2Ban</a>'
@app.route('/api/v1', methods=['GET'])
@app.route('/api/v1/', methods=['GET'])
@cache.cached(timeout=3600)
def help():
    return '/api - About<br/>/api/v1 - Help<br/>/api/v1/time/[str:jailname]/[int:hour]/[all] - Banned IPs by time (last n hours)<br/>/api/v1/count/[str:jailname]/[int:count]/[all] - Banned IPs by count (n bans)<br/>args: domain=domain_filter, time=time_filter_in_hours'


# These are IPs that have been bad for a short ban
@app.route('/api/v1/time', methods=['GET'])
@app.route('/api/v1/time/', methods=['GET'])
@app.route('/api/v1/time/<string:jail>', methods=['GET'])
@app.route('/api/v1/time/<string:jail>/', methods=['GET'])
@app.route('/api/v1/time/<string:jail>/<int:time>', methods=['GET'])
@app.route('/api/v1/time/<string:jail>/<int:time>/', methods=['GET'])
@app.route('/api/v1/time/<string:jail>/<int:time>/<string:host>', methods=['GET'])
@app.route('/api/v1/time/<string:jail>/<int:time>/<string:host>/', methods=['GET'])
@cache.cached(timeout=5)
def gettime(jail="ssh", time=1, host="remote"):
    if host == "remote":
        try:
            host = socket.gethostbyaddr(request.remote_addr)[0]
        except socket.herror:
            host = "unknown.host"
    else:
        host = "*"

    filter=""
    if 'domain' in request.args:
        filter = filter+" AND hostname like '%%%s'" % (escape(request.args.get('domain', default=None, type=str)))

    jail = jail.lower()
    if filter:
        sql = "SELECT UNIX_TIMESTAMP(created) as created, ip, port, protocol FROM f2b WHERE created>=DATE_ADD(NOW(), INTERVAL -%s HOUR) AND jail = '%s' AND hostname != '%s' %s" % (int(time), escape(jail), escape(host), filter)
    else:
        sql = "SELECT UNIX_TIMESTAMP(created) as created, ip, port, protocol FROM f2b WHERE created>=DATE_ADD(NOW(), INTERVAL -%s HOUR) AND jail = '%s' AND hostname != '%s'" % (int(time), escape(jail), escape(host))
    db = mysql.connector.connect(host=cfg.mysql["host"], user=cfg.mysql["user"], passwd=cfg.mysql["passwd"], db=cfg.mysql["db"])
    cur = db.cursor(dictionary=True)
    cur.execute(sql)
    row = cur.fetchall()
    return jsonify(row)

# These are IPs that are repeatedly bad
@app.route('/api/v1/count', methods=['GET'])
@app.route('/api/v1/count/', methods=['GET'])
@app.route('/api/v1/count/<string:jail>', methods=['GET'])
@app.route('/api/v1/count/<string:jail>/', methods=['GET'])
@app.route('/api/v1/count/<string:jail>/<int:count>', methods=['GET'])
@app.route('/api/v1/count/<string:jail>/<int:count>/', methods=['GET'])
@app.route('/api/v1/count/<string:jail>/<int:count>/<string:host>', methods=['GET'])
@app.route('/api/v1/count/<string:jail>/<int:count>/<string:host>/', methods=['GET'])
@cache.cached(timeout=5)
def getcount(jail="all", count=1000, host="remote"):
    if host == "remote":
        try:
            host = socket.gethostbyaddr(request.remote_addr)[0]
        except socket.herror:
            host = "unknown.host"
    else:
        host = "*"

    filter=""
    if 'domain' in request.args:
        filter = filter+" AND hostname like '%%%s'" % (escape(request.args.get('domain', default=None, type=str)))
    if 'time' in request.args:
        filter = filter+" AND created>=DATE_ADD(NOW(), INTERVAL -%d HOUR)" % (request.args.get('time', default=None, type=int))

    jail = jail.lower()
    if jail == "all":
        jailsql = ""
    else:
        jailsql = "jail = '%s' AND" % (escape(jail))

    if filter:
        sql = "SELECT COUNT(*) as count, ip, port, protocol FROM f2b WHERE %s hostname != '%s' %s GROUP BY ip HAVING count >= %d ORDER BY count DESC" % (jailsql, escape(host), filter, int(count))
    else:
        sql = "SELECT COUNT(*) as count, ip, port, protocol FROM f2b WHERE %s hostname != '%s' GROUP BY ip HAVING count >= %d ORDER BY count DESC" % (jailsql, escape(host), int(count))
    cur.execute(sql)
    row = cur.fetchall()
    return jsonify(row)

# A method to write back into the database
@app.route('/api/v1/put', methods=['PUT'])
def put():
    cur2 = db.cursor(dictionary=True
    if 'X-TOKEN' in request.headers:
        tokensql = "SELECT COUNT(*) as count FROM f2b_api WHERE `key` = '%s'" % (request.headers.get('X-TOKEN', default=None, type=str))
        cur2.execute(tokensql)
        row = cur2.fetchall()
        if int(row[0]['count']) >= 1:

            if 'date' not in request.json:
                return "Incomplete request - date"
            else:
                pdate = request.json['date']
            if 'jail' not in request.json:
                return "Incomplete request - jail"
            else:
                pjail = request.json['jail']
                pjail = pjail.lower()
            if 'proto' not in request.json:
                return "Incomplete request - proto"
            else:
                pproto = request.json['proto']
            if 'port' not in request.json:
                return "Incomplete request - port"
            else:
                pport = request.json['port']
            if 'ip' not in request.json:
                return "Incomplete request - ip"
            else:
                pip = request.json['ip']
            # Optional
            if 'hostname' not in request.json:
                try:
                    phost = socket.gethostbyaddr(request.remote_addr)[0]
                except socket.herror:
                    return "Unable to determine your hostname, please include it in the request"
            else:
                phost = request.json['hostname']
            if 'bantime' not in request.json:
                pbantime = "900"
            else:
                pbantime = request.json['bantime']

            sql = "INSERT INTO f2b SET hostname = '%s', created = '%s', jail = '%s', protocol = '%s', port = '%s', ip = '%s', bantime = '%d'" % (escape(phost), escape(pdate), escape(pjail), escape(pproto), escape(pport), escape(pip), int(pbantime))
            cur2.execute(sql)
            db.commit()
       	    print("PUT - SQL: ",sql, " from ", request.remote_addr)
            print("PUT - ", cur.rowcount, " records inserted.")
       	    if cur2.rowcount > 0:
       	        return "OK"
       	    else:
                return "FAILED"
        else:
            return "Please PUT request with your TOKEN."
    else:
        return "Please PUT request with your TOKEN."


if __name__ == "__main__":
    app.run()
