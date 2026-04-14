#!/bin/bash

# 1. Ensure directories exist and have right permissions
mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql /run/mysqld

# 2. Initialize MariaDB data directory if it's empty
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# 3. Start the daemon
mysqld_safe --datadir=/var/lib/mysql &

# 4. Wait loop
until mysqladmin ping >/dev/null 2>&1; do
    echo "Waiting for MariaDB to wake up..."
    sleep 2
done

# ... rest of your script ...