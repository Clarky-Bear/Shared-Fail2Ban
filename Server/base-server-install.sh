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
    pmopts="install -q -y"
    pgs="mariadb-server mariadb"
    if [ $ver -ge 8 ]; then
      pm="dnf"
    elif [ $ver -eq 7 ]; then
      pm="yum"
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

echo "Starting DB"
check_bin systemctl
systemctl enable mariadb >/dev/null 2>&1
systemctl start mariadb >/dev/null 2>&1

echo "Configuring MySQL"
curl --silent https://raw.githubusercontent.com/bulgemonkey/Shared-Fail2Ban/master/Server/base-server.sql -o ~/base-server.sql
mysql -u root < ~/base-server.sql
