CREATE DATABASE f2b;
CREATE TABLE f2b.f2b ( `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,   `hostname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,   `created` datetime NOT NULL,   `jail` text COLLATE utf8_unicode_ci NOT NULL,   `protocol` varchar(16) COLLATE utf8_unicode_ci NOT NULL,   `port` varchar(32) COLLATE utf8_unicode_ci NOT NULL,   `ip` varchar(64) COLLATE utf8_unicode_ci NOT NULL,  `bantime` varchar(32) COLLATE utf8_unicode_ci NOT NULL,   PRIMARY KEY (`id`),   KEY `hostname` (`hostname`,`ip`) );
CREATE TABLE f2b.f2b_api ( `key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL, `clientip` varchar(128) COLLATE utf8_unicode_ci NOT NULL,   `desc` varchar(255) COLLATE utf8_unicode_ci NOT NULL,   PRIMARY KEY (`key`) );


c54dvX9jJUFz5DM6
