#!/bin/bash
#
# Shared Fail2Ban Installer
# 2020 - Adam Boutcher, Paul Clark
# (UKI-SCOTGRID-DURHAM) IPPP, Durham University
#
# This script attempts to install Fail2Ban and install the
#  Shared Fail2Ban Scripts
# Tested with CentOS
#

# Install Type (api or sql)
TYPE="api"

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

check_bin which
check_bin which
check_bin cat
check_bin grep
check_bin awk
check_bin tr
check_bin mkdir
check_bin curl

distro=$(cat /etc/os-release | grep -m 1 ID | awk -F "=" '{print tolower($2)}' | tr -d '"')
ver=$(cat /etc/os-release | grep -m 1 VERSION_ID | awk -F "=" '{print $2}' | tr -d '"')

echo "Checking Distro:"
case $distro in
  "centos" | "scientific" | "redhat" | "rhel")
    echo " - RHEL"
    setsebool -P nis_enabled 1 >/dev/null 2>&1
    pmopts="install -q -y"
    pgs="fail2ban fail2ban-server fail2ban-firewall fail2ban-selinux"
    if [ $ver -ge 8 ]; then
      pm="dnf"
      if [ $TYPE == 'sql' ]; then
        pgs=$pgs" pip3"
      fi
    elif [ $ver -eq 7 ]; then
      pm="yum"
      if [ $TYPE == 'sql' ]; then
        pgs=$pgs" python3-pip"
      fi
    else
      echo "CentOS version unsupported."
      exit 1
    fi
    ;;
  *)
    echo "Unknown Distro"
    exit 1
esac

echo "Installing Packages"
check_bin $pm
$pm $pmopts $pgs >/dev/null 2>&1

if [ $TYPE == 'sql' ]; then
  check_bin pip3
  pip3 -q install mysql-connector >/dev/null 2>&1
fi

mkdir -p /etc/fail2ban/action.d/shared-f2b
check_bin curl
curl --silent https://raw.githubusercontent.com/bulgemonkey/Shared-Fail2Ban/master/fail2ban/action.d/shared-f2b-input.py -o /etc/fail2ban/action.d/shared-f2b-input.py
curl --silent https://raw.githubusercontent.com/bulgemonkey/Shared-Fail2Ban/master/fail2ban/action.d/shared-f2b/input.py -o /etc/fail2ban/action.d/shared-f2b/input.py
curl --silent https://raw.githubusercontent.com/bulgemonkey/Shared-Fail2Ban/master/fail2ban/action.d/shared-f2b/get.py -o /etc/fail2ban/action.d/shared-f2b/get.py
curl --silent https://raw.githubusercontent.com/bulgemonkey/Shared-Fail2Ban/master/fail2ban/filter.d/shared-f2b-filter.conf -o /etc/fail2ban/filter.d/shared-f2b-filter.conf

echo "Configuring"
curl --silent https://raw.githubusercontent.com/bulgemonkey/Shared-Fail2Ban/master/fail2ban/cron/fail2ban-shared -o /etc/cron.d/fail2ban-shared
touch /etc/fail2ban/action.d/shared-f2b/filter.log
touch /etc/fail2ban/action.d/shared-f2b/shared_cfg.py
# Copy the api script to here
cat << EOF > /etc/fail2ban/action.d/shared-f2b/shared_cfg.py
#!python

#api or mysql
source = "api"

mysql = {
  "host": "localhost",
  "user": "user",
  "passwd": "password",
  "db": "f2b",
}

apiurl = "https://f2bapi/api/v1"
apitoken = "blah"
EOF

echo "Finish your config in the jail.conf and shared_cfg.py"
