FROM debian:bookworm

# Instalar servidor y cliente de MariaDB
RUN apt-get update && \
    apt-get install -y \
        mariadb-server \
        mariadb-client

# Crear directorio para el socket y el PID de MariaDB
RUN mkdir -p /var/run/mysqld && \
    chown mysql:mysql /var/run/mysqld

# Copiar configuracion personalizada del servidor
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copiar script de inicializacion
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# # Verificacion de salud del contenedor
# HEALTHCHECK --interval=10s --timeout=5s --retries=5 --start-period=30s \
#     CMD mysqladmin ping -h localhost --silent || exit 1

ENTRYPOINT ["entrypoint.sh"]