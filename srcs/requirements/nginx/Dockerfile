FROM debian:bullseye

# 1. Install Nginx and OpenSSL
RUN apt-get update && apt-get install -y \
    nginx \
    openssl 

# 2. Setup SSL (Self-signed certificate)
#/etc system wide where configuration files are stored
RUN mkdir -p /etc/nginx/ssl
#req -x509 → create a self-signed certificate instead of a certificate request
#nodes → do not encrypt the private key (no passphrase)
#days 365 → certificate is valid for 365 days
#rsa:2048 → generate a 2048-bit RSA key
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    #generate a new private key and a self-signed certificate
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    #subject → specify the subject of the certificate (country, state, locality, organization, organizational unit, common name)
    -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=42/CN=mcamaren.42.fr"

# 3. Handle Configuration
# Remove the default Debian config to avoid conflicts
RUN rm -f /etc/nginx/sites-enabled/default
# Copy your custom config
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# 4. Prepare Nginx to run
RUN mkdir -p /run/nginx

# Inception usually requires port 443 for SSL
EXPOSE 443

# Run in foreground
CMD ["nginx", "-g", "daemon off;"]