#!/bin/bash
set -e
if [ -n "$MYSQL_PORT_3306_TCP" ]; then
		if [ -z "$INTEGRIA_DB_HOST" ]; then
			INTEGRIA_DB_HOST='mysql'
		else
			echo >&2 'warning: both INTEGRIA_DB_HOST and MYSQL_PORT_3306_TCP found'
			echo >&2 "  Connecting to INTEGRIA_DB_HOST ($INTEGRIA_DB_HOST)"
			echo >&2 '  instead of the linked mysql container'
		fi
fi

if [ -z "$INTEGRIA_DB_HOST" ]; then
	echo >&2 'error: missing INTEGRIA_DB_HOST and MYSQL_PORT_3306_TCP environment variables'
	echo >&2 '  Did you forget to --link some_mysql_container:mysql or set an external db'
	echo >&2 '  with -e INTEGRIA_DB_HOST=hostname:port?'
	exit 1
fi

# if we're linked to MySQL and thus have credentials already, let's use them
: ${INTEGRIA_DB_USER:=${MYSQL_ENV_MYSQL_USER:-root}}
if [ "$INTEGRIA_DB_USER" = 'root' ]; then
	: ${INTEGRIA_DB_PASSWORD:=$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
fi
: ${INTEGRIA_DB_PASSWORD:=$MYSQL_ENV_MYSQL_PASSWORD}
if [ -z "$INTEGRIA_DB_NAME" ]; then
	: ${INTEGRIA_DB_NAME:=${MYSQL_ENV_MYSQL_DATABASE:-integria}}
fi

if [ -z "$INTEGRIA_DB_PASSWORD" ]; then
	echo >&2 'error: missing required INTEGRIA_DB_PASSWORD environment variable'
	echo >&2 '  Did you forget to -e INTEGRIA_DB_PASSWORD=... ?'
	echo >&2
	echo >&2 '  (Also of interest might be INTEGRIA_DB_USER and INTEGRIA_DB_NAME.)'
	exit 1
fi

echo "Initializing the database"
mysql -u $INTEGRIA_DB_USER -p$INTEGRIA_DB_PASSWORD -h $INTEGRIA_DB_HOST $INTEGRIA_DB_NAME < /tmp/integriaims/integria_db.sql
mysql -u $INTEGRIA_DB_USER -p$INTEGRIA_DB_PASSWORD -h $INTEGRIA_DB_HOST $INTEGRIA_DB_NAME < /tmp/integriaims/integria_dbdata.sql
echo "Done with the database"

mv -f /tmp/integriaims /var/www/html/integria
cd /var/www/html/integria/include

touch config.php
echo "<?php" >> config.php
echo "\$config[\"dbname\"]=\"$INTEGRIA_DB_NAME\";" >> config.php
echo "\$config[\"dbuser\"]=\"$INTEGRIA_DB_USER\";" >> config.php
echo "\$config[\"dbpass\"]=\"$INTEGRIA_DB_PASSWORD\";" >> config.php
echo "\$config[\"dbhost\"]=\"$INTEGRIA_DB_HOST\";" >> config.php
echo "include (\$ownDir . \"config_process.php\");" >> config.php

cat >> config.php <<- 'EOF'
// Display ALL errors until redirect to integria error log
error_reporting(E_ALL);

$path = dirname (__FILE__);
$ownDir = dirname(__FILE__) . DIRECTORY_SEPARATOR;
?>
EOF


echo "Granting apache permissions to the console directory"
chown -R apache:apache /var/www/html/integria
chmod 600 /var/www/html/integria/include/config.php

# Customize php.ini
echo "Configuring Integria IMS elements and depending services"
sed "s/.*max_execution_time =.*/max_execution_time = 0/" /etc/php.ini > /tmp/php.ini && mv /tmp/php.ini /etc/php.ini
sed "s/.*max_input_time =.*/max_input_time = -1/" /etc/php.ini > /tmp/php.ini && mv /tmp/php.ini /etc/php.ini
sed "s/.*upload_max_filesize =.*/upload_max_filesize = 800M/" /etc/php.ini > /tmp/php.ini && mv /tmp/php.ini /etc/php.ini
sed "s/.*memory_limit =.*/memory_limit = 500M/" /etc/php.ini > /tmp/php.ini && mv /tmp/php.ini /etc/php.ini
sed "s/.*post_max_size =.*/post_max_size = 100M/" /etc/php.ini > /tmp/php.ini && mv /tmp/php.ini /etc/php.ini

cd /var/www/html/integria && mv -f install.php install.php.done


#Rock n' roll!
/etc/init.d/crond start &
/etc/init.d/ntpd start &

rm -rf /run/httpd/*
exec /usr/sbin/apachectl -D FOREGROUND
