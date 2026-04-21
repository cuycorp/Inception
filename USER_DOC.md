# Inception – User Guide

This document offers a high-level, non-technical introduction to the infrastructure. It explains how to use the platform, access administrative interfaces, and confirm that all services are running correctly.


## 1. Overview of Services

The Inception project delivers a complete web stack composed of three core services, each responsible for a specific layer:

| Service | Role | Main Features | Access |
| :--- | :--- | :--- | :--- |
| **NGINX** | **Secure Gateway** | Handles incoming HTTPS requests, performs SSL termination, and enforces TLS 1.2/1.3 encryption. | Port `443` (Public) |
| **WordPress** | **Application Layer** | Provides the CMS interface for managing content, users, themes, and plugins. | Internal (via NGINX) |
| **MariaDB** | **Data Layer** | Stores all application data (posts, users, settings) with persistent volumes. | Port `3306` (Private) |



## 2. Starting and Stopping the Project

### 🛠️ Management Commands (Makefile)

A `Makefile` is provided to simplify Docker Compose operations. Run commands from the project root:

| Command | Purpose | Description |
| :--- | :--- | :--- |
| `make` | **Start** | Builds images, initializes directories, and launches all services in detached mode. Creates `~/data/wordpress` and `~/data/maria-db`. |
| `make stop` | **Stop** | Halts running containers without removing them. |
| `make start` | **Restart** | Starts previously stopped containers. |
| `make down` | **Remove** | Stops and deletes containers and networks. |
| `make clean` | **Reset (Soft)** | Removes containers and Docker volumes. |
| `make fclean` | **Reset (Hard)** | Performs a full cleanup, including images and **local data deletion**. |
| `make re` | **Rebuild** | Executes a full reset followed by a fresh build. |
| `make logs` | **Logs** | Displays real-time logs for all services. |
| `make ps` | **Status** | Shows container states and health. |

> ⚠️ **Warning**: `make fclean` permanently deletes all stored data, including database content and uploaded media.



## 3. Accessing the Website

### 🌐 Website

Once services are running, open the site in your browser:

**URL**: https://mcamaren.42.fr  

**Notes:**
- Only HTTPS is supported.
- If a browser warning appears (self-signed certificate):  
  → Click **Advanced** → **Accept Risk and Continue**


### 🔐 WordPress Admin Panel

Access the dashboard here:

**URL**: https://mcamaren.42.fr/wp-login.php

**Admin Credentials**
- Username: defined in `.env` (`WORDPRESS_ADMIN_USER`)
- Password: stored in `secrets/wp_admin_password.txt`

**Standard User**
- Username: defined in `.env` (`WORDPRESS_USER`)
- Password: stored in `secrets/wp_user_password.txt`



If the site fails to load:

| Step | Action | Command | Expected Result |
| :--- | :--- | :--- | :--- |
| 1 | Check containers | `make ps` | All services should be **Up** |
| 2 | Verify hosts entry | `cat /etc/hosts \| grep mcamaren` | Should show `127.0.0.1 mcamaren.42.fr` |
| 3 | Add host entry | `echo "127.0.0.1 mcamaren.42.fr" \| sudo tee -a /etc/hosts` | Run only if missing |



## 4. Credentials Management

### Credential Location #### 1. **Docker Secrets** (Passwords) All sensitive credentials are stored in secrets/ directory,
secrets/
├── db_password.txt          # Database user password
├── db_root_password.txt     # Database root password
├── wordpress_admin_password.txt    # WordPress admin password
└── wordpress_user_password.txt     # WordPress second user password
#### 2. **Environment Variables** (Usernames, Emails, URLs) 

The rest of credentilas are stored in srcs/.env file: **Types of Variable**:
 - MariaDB Configuration 
 - WordPress Database Connection 
 - Wordpress website configuration 
 - Admin user 
 - Additional user


### Status Check

Use this command to view all running containers:

```bash
make ps
```

**Examples of expected output** : the three services should have UP status
```
NAME        IMAGE            COMMAND                  SERVICE     CREATED        STATUS             PORTS
mariadb     srcs-mariadb     "entrypoint.sh"          mariadb     16 hours ago   Up 2 hours         
nginx       srcs-nginx       "nginx -g 'daemon of…"   nginx       16 hours ago   Up About an hour   0.0.0.0:443->443/tcp, [::]:443->443/tcp
wordpress   srcs-wordpress   "/setup.sh"              wordpress   16 hours ago   Up About an hour  
```