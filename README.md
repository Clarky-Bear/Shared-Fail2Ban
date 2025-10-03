# Shared Fail2Ban

## Project Outline

This project aims to enable [Fail2Ban](https://www.fail2ban.org/) instances on individual systems to push the ban information of each jail to a central database allowing other systems to pull the bans to their own system.

**Example:**
This would then mean if Alice and Bob both share their bans and Charlie was locked out from Alice's system for too many incorrect details, Charlie would then be banned from Bob's system.

By default systems will only be provided a list of bans that do not originate from themselves, for instance, Alice will not be given their own ban list back; however if Bob bans the same address at the same time (for example, a automated simultaneous attack) then Alice will be given the same address back as Bob banned it too.

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

### Notice - Linux Compatability
The initial development for the Shared Fail2Ban was on CentOS 7 (EL7), with some minor alterations to support CentOS 8 (EL8).
We have since deployed both the server and client on Rocky Linux 9 (EL9) with no issues.
We cannot forsee any issues with other Linux Based systems (especially Fedora, Ubuntu, Debian etc) however we have not tested these so other distros may have unexpected results.

#### SELinux
SELinux may break this, we wrote some modules for our environment but they have not been included in this project yet.
- Fail2Ban Client - setsebool -P nis_enabled 1
- Fail2Ban API - setsebool -P httpd_can_network_connect_db

#### Python Support
Fail2Ban originally shipped with a custom fixed version of Python (python2) which is what we targeted with all of our scripts, since then, Python2 has been deprcated and Fail2Ban seems to use the system Python3. All of our scripts work with the current version of python shipped (EL9, Python 3.9), most client scripts should work on the older Python2 deployment however your experiences may vary.

#### Notice - IPv6
Fail2Ban didn't support IPv6 at the time of initial development. We have seen *some* IPv6 addresses in our shared fail2ban deployment however the current state of this project is that IPv6 is *still* (as of 2025) considered untested and will probably not work as intended.

----

### Auto Deployment

Here's a list of other attempts at auto deployment. They may bundle older versions of the scripts and should be used as reference only.
- [Puppet](https://github.com/adamboutcher/Shared-Fail2Ban-Puppet)
- [Ansible](https://github.com/ninelocks/ansible-shared-fail2ban)

----
### Other related works
- [Shared Ban Exports](https://github.com/adamboutcher/Shared-Fail2Ban-Exports)
