#!/bin/bash
echo "Granting apache permissions to the console directory"
chown -R apache:apache /var/www/html/
chmod 600 /var/www/html/include/config.php

#Rock n' roll!
/etc/init.d/crond start &
/etc/init.d/ntpd start &

rm -rf /run/httpd/*
exec /usr/sbin/apachectl -D FOREGROUND
