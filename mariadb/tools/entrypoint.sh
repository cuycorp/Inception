#!/bin/bash
set -e

# Solo inicializar si la base de datos no existe todavia
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "Primera ejecucion: inicializando base de datos..."

    # Inicializar el directorio de datos de MariaDB, para no poner stdout o stderr
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    # Arrancar el servidor en modo bootstrap para ejecutar SQL de configuracion
    mariadbd --user=mysql --bootstrap <<-EOSQL # para ejecutar commandos de bases de datos
		FLUSH PRIVILEGES;

		-- Contrasena de root en duro
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

		-- Base de datos de WordPress
		CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

		-- Usuario de WordPress con contrasena en duro
		-- % es para permitir conexiones desde cualquier host, necesario para la comunicacion con el contenedor de WordPress
		CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}'; 

		GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

		FLUSH PRIVILEGES;
	EOSQL

    echo "Base de datos inicializada correctamente."
else
    echo "Base de datos ya existe, saltando inicializacion."
fi

echo "Iniciando MariaDB..."
exec mariadbd --user=mysql ##ejecutar el servidor de MariaDB en primer plano, para que el contenedor no se detenga