## Shared Fail2Ban API

This API is written in Flask/Python3.
The install scripts has been briefly tested on CentOS7 and CentOS8.

The idea is to de-couple the need for each Fail2Ban Client to have direct access to a MySQL Database.
This should allow the IP lists being generated to also be intergrated into other systems.

Ensure you create the f2b_api table and give your database user access
e.g. - GRANT SELECT,INSERT ON f2b.f2b_api TO 'user'@'192.168.1.1' IDENTIFIED BY 'password';
