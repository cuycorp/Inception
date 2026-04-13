#!/bin/bash

# Ensure PHP-FPM run directory exists
mkdir -p /run/php

mkdir -p /var/www/html
cd /var/www/html

# Download WordPress
if [ ! -f wp-config.php ]; then
    wget https://wordpress.org/latest.tar.gz
    tar -xvf latest.tar.gz --strip-components=1
    rm latest.tar.gz
fi

# Configure WordPress
cp wp-config-sample.php wp-config.php

# Matching the variable names from your compose.yml
sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" wp-config.php
sed -i "s/username_here/$WORDPRESS_DB_USER/" wp-config.php
sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" wp-config.php
sed -i "s/localhost/$WORDPRESS_DB_HOST/" wp-config.php

exec /usr/sbin/php-fpm7.4 -F