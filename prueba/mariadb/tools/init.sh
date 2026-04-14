#!/bin/bash

# Start MariaDB temporarily
service mariadb start

# Wait for it to be ready
sleep 2

# Create DB and user from env variables
mysql -u root -p$MYSQL_ROOT_PASSWORD <<EOF
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF

# Stop temporary server
mysqladmin -u root -p$MYSQL_ROOT_PASSWORD shutdown

# Start MariaDB in foreground (REQUIRED)
exec mysqld_safe