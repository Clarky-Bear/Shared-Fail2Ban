# Shared Fail2Ban
*A poor attempt at unifying bans over multiple hosts*

## !!!! WARNING !!!! ##
This Repository is currently in a development state.
We are not professional developers, so it's highly likely that this doesn't yet work.
Please use this only as a guide; do not use this work in production and if you do, expect things to set on fire.

This probably doesn't work with IPv6 (Fail2Ban didn't initially support IPv6 when this was developed.).

## Guide ##
0. Install Fail2Ban
1. Create the database
2. Input scripts into Fail2Ban
3. Add Jails
4. Schedule cron scripts
5. ???
6. Profit!

## API ##
The API was developed to allow a better method of sharing ban data; it's written in Flask/Python. The aim is to keep the MySQL Database more secure as well as dealing with NAT'd in a much more secure way.
## Known Issues ##
1. This targets CentOS7 / RHEL7 Based Linux systems, some directories and locations may be wrong.
2. SELinux may stop the scripts from operating; we wrote our own module for our test system which will be provided at a later date.

## About ##
This repository is for the **Shared Fail2Ban** system initially developed by **Paul Clark** and contributed to by **Adam Boutcher** while working at [Durham University](https://www.dur.ac.uk).
