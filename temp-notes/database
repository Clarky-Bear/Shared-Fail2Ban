#Basic database and table build to store fail2ban entries

Create database fail2ban
CREATE TABLE fail2ban ( `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,   `hostname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,   `created` datetime NOT NULL,   `name` text COLLATE utf8_unicode_ci NOT NULL,   `protocol` varchar(16) COLLATE utf8_unicode_ci NOT NULL,   `port` varchar(32) COLLATE utf8_unicode_ci NOT NULL,   `ip` varchar(64) COLLATE utf8_unicode_ci NOT NULL,  `bantime` varchar(32) COLLATE utf8_unicode_ci NOT NULL,   PRIMARY KEY (`id`),   KEY `hostname` (`hostname`,`ip`) );

CREATE USER 'fail1' IDENTIFIED BY 'password';

#Suggested change to allow only read, write and modify access to fail user
GRANT ALL privileges ON `fail2ban`.'fail2ban' TO 'fail1'@'172.16.2.%';

SELECT User, Host FROM mysql.user WHERE Host <> 'localhost';

flush privileges

