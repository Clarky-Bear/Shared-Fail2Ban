#!/bin/bash
#
# Shared Fail2Ban API Installer
# 2020 - Adam Boutcher, Paul Clark
# (UKI-SCOTGRID-DURHAM) IPPP, Durham University
#
# This script attempts to install mod_wsgi and setup apache to run
#  a python3 flask API.
# Tested with CentOS. Experimental support for Fedora and Ubuntu
#

PREFIX="/opt"
APIHOST="f2bapi.dur.scotgrid.ac.uk"
APIALT="f2bapi"

if [ ! -f /etc/os-release ]; then
  echo "Cannot determine Linux Distro";
  exit 1
fi

# Function to check that a binary exists
function check_bin() {
  which $1 1>/dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    echo "$1 cannot be found. Please install it or add it to the path. Exiting."
    exit 1
  fi
}

# Early Binary Checks
check_bin which
check_bin cat
check_bin grep
check_bin awk
check_bin tr
check_bin fold

distro=$(cat /etc/os-release | grep -m 1 ID | awk -F "=" '{print tolower($2)}' | tr -d '"')
ver=$(cat /etc/os-release | grep -m 1 VERSION_ID | awk -F "=" '{print $2}' | tr -d '"')

echo "Checking Distro:"
case $distro in
  "fedora")
    echo " - Fedora (Experimental)"
    setsebool -P httpd_can_network_connect_db 1  >/dev/null 2>&1
    pmopts="install -q -y"
    abin="httpd"
    if [ $ver -ge 32 ]; then
      pm="dnf"
      pgs="httpd mod_wsgi python3 python3-pip"
      cmd="manual"
    fi
    ;;
  "centos" | "scientific" | "redhat" | "rhel")
    echo " - RHEL"
    pmopts="install -q -y"
    abin="httpd"
    setsebool -P httpd_can_network_connect_db 1  >/dev/null 2>&1
    if [ $ver -ge 8 ]; then
      pm="dnf"
      pgs="httpd python3-mod_wsgi python36 python3-pip"
      cmd="manual"
    elif [ $ver -eq 7 ]; then
      pm="yum"
      pgs="httpd gcc httpd-devel python36 python36-devel python3-pip python36-virtualenv"
      cmd="manual"
      compat="pip3"
    else
      echo "CentOS version unsupported."
      exit 1
    fi
    ;;
  "ubuntu")
    echo " - Ubuntu 20.04 (Experimental)"
    pmopts="install -q -y"
    abin="apache2"
    pm="apt-get"
    pgs="apache2 libapache2-mod-wsgi python3 python3-pip python3-virtualenv"
    cmd="auto"
    ;;
  *)
    echo "Unknown Distro"
    exit 1
esac

echo "Installing Packages"
check_bin $pm
$pm $pmopts $pgs >/dev/null 2>&1

if [ -d "/etc/httpd" ]; then
  aloc="/etc/httpd"
elif [ -d "/etc/apache2" ]; then
  aloc="/etc/apache2"
else
  echo "Unknown Apache Location"
  exit 1
fi

if [ ! -z $compat ] && [ $compat == "pip3" ]; then
  check_bin pip3
  pip3 install mod-wsgi
  cp /usr/local/lib64/python3.6/site-packages/mod_wsgi/server/mod_wsgi-py36.cpython-36m-x86_64-linux-gnu.so $aloc/modules/mod_wsgi.so
fi

echo "Creating Python3 VirtualEnv"
python3 -m virtualenv $PREFIX/f2bapi >/dev/null 2>&1
if [ $? -ne 0 ]; then
  python3 -m venv $PREFIX/f2bapi >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Cannot find Python3 VirtualEnv"
  fi
fi

echo "Building Python3 VirtualEnv"
source $PREFIX/f2bapi/bin/activate
check_bin pip3
pip3 install flask >/dev/null 2>&1
pip3 install flask-caching >/dev/null 2>&1
pip3 install mysql-connector >/dev/null 2>&1

echo "Configuring Apache"
if [ $cmd == "manual" ]; then
  if [ -f "$aloc/modules/mod_wsgi.so" ]; then
    echo "LoadModule wsgi_module modules/mod_wsgi.so" > $aloc/conf.modules.d/05-wsgi.conf
  else
    echo "LoadModule wsgi_module modules/mod_wsgi_python3.so" > $aloc/conf.modules.d/05-wsgi.conf
  fi
else
  check_bin a2enmod
  a2enmod mod_wsgi -q >/dev/null 2>&1
fi

touch $aloc/conf.d/api.conf
cat << EOF > $aloc/conf.d/api.conf
<VirtualHost *:80>
     #ServerName $APIHOST
     #ServerAlias $APIALT
     WSGIScriptAlias / $PREFIX/f2bapi/api.wsgi
     <Directory $PREFIX/f2bapi>
                # set permissions as per apache2.conf file
            Options FollowSymLinks
            AllowOverride None
            Require all granted
     </Directory>
     LogLevel warn
</VirtualHost>
EOF

RNDM=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
touch $PREFIX/f2bapi/api.wsgi
cat << EOF > $PREFIX/f2bapi/api.wsgi
#!/usr/bin/python3.6

import logging
import sys
logging.basicConfig(stream=sys.stderr)
sys.path.insert(0, '$PREFIX/f2bapi/lib/python3.6/site-packages')
sys.path.insert(1, '$PREFIX/f2bapi/bin')
sys.path.insert(2, '$PREFIX/f2bapi/')
from api import app as application
application.secret_key = '$RNDM'
EOF

touch $PREFIX/f2bapi/api.py
check_bin curl
curl --silent https://raw.githubusercontent.com/bulgemonkey/Shared-Fail2Ban/master/Server/API/api.py -o $PREFIX/f2bapi/api.py
touch $PREFIX/f2bapi/api_cfg.py
# Copy the api script to here
cat << EOF > $PREFIX/f2bapi/api_cfg.py
#!/usr/bin/python3
mysql = {
  "host": "localhost",
  "user": "user",
  "passwd": "password",
  "db": "f2b",
}
EOF

echo "Final Check"
check_bin flask

echo "Starting Apache:"
which systemctl >/dev/null 2>&1
if [ $? -eq 0 ]; then
  systemctl enable $abin >/dev/null 2>&1
  systemctl start $abin >/dev/null 2>&1
else
  update-rc.d $abin enable >/dev/null 2>&1
  service $abin start >/dev/null 2>&1
  initctl $abin start >/dev/null 2>&1
fi
if [ $? -eq 0 ]; then
  echo " - Started"
else
  echo " - Failed to start"
fi

echo "Completed"
