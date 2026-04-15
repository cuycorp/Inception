FROM debian:bullseye

# 1. Install Nginx and OpenSSL
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# 2. Setup SSL (Self-signed certificate)
RUN mkdir -p /etc/nginx/ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
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