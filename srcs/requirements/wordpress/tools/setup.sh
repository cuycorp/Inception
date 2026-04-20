#!/bin/bash

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WORDPRESS_ADMIN_PASSWORD=$(cat /run/secrets/wordpress_admin_password)
WORDPRESS_USER_PASSWORD=$(cat /run/secrets/wordpress_user_password)

# Ensure PHP-FPM run directory exists
mkdir -p /run/php


mkdir -p /var/www/html
cd /var/www/html

# Download WordPress
# if [ ! -f wp-config.php ]; then
#     wget https://wordpress.org/latest.tar.gz
#     tar -xvf latest.tar.gz --strip-components=1
#     rm latest.tar.gz
# fi

# # Configure WordPress
# cp wp-config-sample.php wp-config.php

# # Matching the variable names from your compose.yml
# sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" wp-config.php
# sed -i "s/username_here/$MYSQL_USER/" wp-config.php
# sed -i "s/password_here/$MYSQL_PASSWORD/" wp-config.php
# sed -i "s/localhost/$WORDPRESS_DB_HOST/" wp-config.php

# exec /usr/sbin/php-fpm7.4 -F

# Télécharger WordPress si absent
if [ ! -f wp-load.php ]; then
    wp core download --allow-root
fi

# Créer wp-config.php si absent, connect WordPress à la base de données mariadb
if [ ! -f wp-config.php ]; then
    wp config create \
        --dbname="${WORDPRESS_DB_NAME}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="${WORDPRESS_DB_HOST}" \
        --allow-root
fi

# Installer WordPress si pas encore installé
# This command automates that process by setting the site title, the Admin user, and the admin password instantly.
if ! wp core is-installed --allow-root; then
    wp core install \
        --url="${WORDPRESS_URL}" \
        --title="${WORDPRESS_TITLE}" \
        --admin_user="${WORDPRESS_ADMIN_USER}" \
        --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
        --allow-root
fi

# Sets up a regular user with the role of author, which allows them to create and manage their own posts but not publish them. This is useful for testing different user roles in WordPress.
if ! wp user get "${WORDPRESS_USER}" --allow-root > /dev/null 2>&1; then
    wp user create "${WORDPRESS_USER}" "${WORDPRESS_USER_EMAIL}" \
        --user_pass="${WORDPRESS_USER_PASSWORD}" \
        --role=author \
        --allow-root
fi

exec /usr/sbin/php-fpm7.4 -F #ejecutar el servidor de PHP-FPM en primer plano, para que el contenedor no se detenga
