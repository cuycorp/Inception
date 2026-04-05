FROM debian:bullseye

RUN apt-get update && apt-get install -y procps

RUN apt install mariadb-server mariadb-client galera-4 -y

# Copier le script d'entrée
COPY ./tools/entrypoint.sh /usr/local/bin/entrypoint.sh

# Donner les droits d'exécution
RUN chmod +x /usr/local/bin/entrypoint.sh

# Définir le script comme point d'entrée
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]