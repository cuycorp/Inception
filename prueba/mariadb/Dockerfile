FROM debian:bullseye

RUN apt-get update && apt-get install -y mariadb-server

# CRITICAL: Create the directory for the socket and set ownership
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# Ensure your local file name matches (you listed .conf, but copy .cnf)
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 3306

CMD ["/init.sh"]