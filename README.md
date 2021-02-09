# Shared Fail2Ban

## Project Outline

This project aims to enable [Fail2Ban](https://www.fail2ban.org/) instances on individual systems to push the ban information of each jail to a central database allowing other systems to pull the bans to their own system.

**Example:**
This would then mean if Alice and Bob both share their bans and Charlie was locked out from Alice's system for too many incorrect details, Charlie would then be banned from Bob's system.

Fail2Ban Filters can still be applied meaning the sharing method is as robust as a standard Fail2Ban deployment.

We welcome any Issues and PRs.

## Project Credits

The authors of this project are currently **[Adam Boutcher](https://www.aboutcher.co.uk)** and **Paul Clark**.

This has been developed at the Durham [GridPP](https://gridpp.ac.uk) Site (*UKI-SCOTGRID-DURHAM*) and the [Institute for Particle Physics Phenomenology](https://www.ippp.dur.ac.uk), [Durham University](https://dur.ac.uk).

The work and partial works have been presented too the [WLCG](https://wlcg.web.cern.ch/) Security Operations Centre at [Cern](https://home.cern/)

Other key contributors:
 - **Jon Trinder** at Glasgow University.


----

## Guide

This is a very brief installation method/guide; please read the Warnings and Notices below

### Fail2Ban Host/Client

1. Install Fail2Ban
2. Create the f2b database
3. Choose and setup deployment type (Direct MySQL/MariaDB or API)
4. Deploy the Fail2Ban actions and scripts
5. Configure deployment type
6. Setup the Jails
7. Setup the Cron
8. Start Fail2Ban

### Database (MySQL/MariaDB) Only

1. Run the database scripts
2. Create a db user for each Fail2Ban Host/Client with CREATE and INSERT permissions.
3. Start mysql/mariadb

### API with Database (MySQL/MariaDB)
1. Run the database scripts
2. Create a db user for the API to use with CREATE and INSERT permissions.
3. Run the API insatllation script
4. Make the db changes required
5. Start mysql/mariadb
6. Start httpd/apache


----

## Warnings and Notices

### Warning - Not for Production

The files contained in this repository are currently primarily to use and develop from. They should be READ and UNDERSTOOD rather than blindly copied and deployed.

In no way do we endorse the current scripts as production ready (although they are currently deployed in some production environments), we cannot guarantee their safety, especially as these are aimed for Cyber Security deployments.

### Notice - CentOS

The development for this project has been on CentOS Linux 7 although some efforts have been made to enable them to run on CentOS Linux 8. Other distros may have unexpected results.

#### SELinux

SELinux may break this, we wrote some modules for our environment but they have not been include in this project yet.
- Fail2Ban Client - setsebool -P nis_enabled 1
- Fail2Ban API - setsebool -P httpd_can_network_connect_db

### Warning - IPv6

Fail2Ban didn't support IPv6 at the time of initial development. The current state of this project is that IPv6 is completely untested and will probably not work correctly.

### Notice - Python Support

The version of Fail2Ban we targeted was written in Python2 and shipped with its own python binary, some scripts will run with Python2 and Python3, some are only Python2. Your experiences may vary.
