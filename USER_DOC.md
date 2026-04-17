# Inception - User Documentation

This guide provides a non-technical overview of the infrastructure's services and clear instructions for operating the site, accessing administrative panels, and verifying system health.

---

## 1. Services Overview

The Inception project provides a complete web application stack with three services, each fulfilling a specific layer of the web application stack:

| Service | Primary Role | Key Functionalities | Network Access |
| :--- | :--- | :--- | :--- |
| **NGINX** | **Secure Entry Point** | Acts as a reverse proxy managing HTTPS traffic with TLS 1.2/1.3 encryption and SSL termination. | Port `443` (External) |
| **WordPress** | **Application Engine** | Provides the CMS interface for content creation, user administration, and theme/plugin management. | Internal (via NGINX) |
| **MariaDB** | **Database Storage** | Manages all relational data (posts, users, settings) with persistence through volume mounting. | Port `3306` (Private) |
---

## 2. Start and Stop the Project

## 🛠️ Management Commands (Makefile)

The project uses a `Makefile` to simplify Docker Compose operations. Use these commands from the root directory:

| Command | Action | Description |
| :--- | :--- | :--- |
| `make` | **Launch** | The default rule. Sets up directories and starts all services. Builds the images and starts containers in the background (detached). Creates the local data folders: `~/data/wordpress` and `~/data/maria-db`. |
| `make stop` | **Pause** | Stops the containers without removing them. |
| `make start` | **Resume** | Starts the containers that were previously stopped. |
| `make down` | **Shutdown** | Stops and removes containers and networks. |
| `make clean` | **Soft Reset** | Shuts down the stack and removes Docker-managed volumes. |
| `make fclean` | **Hard Reset** | Executes `clean`, removes all images, and **deletes all host data folders**. |
| `make re` | **Rebuild** | Triggers a full `fclean` followed by a fresh `all`. |
| `make logs` | **Debug** | Streams real-time logs from all running containers. |
| `make ps` | **Status** | Lists all containers and their current health/state. |

> ⚠️ **Warning**: `make fclean` is irreversible. It deletes your actual database files and WordPress media uploads stored on your host machine.

---

## 3. Access the Website

### Website Access

After having the serices running, the website can be accessed through the web browser:

**URL**: https://mcamaren.42.fr 

**Note**
- Use HTTPS only, HTTP is not configured
- If there is a security warning because it uses a self-signed certificate: go to  
    - "Advanced" -> "Accept Risk and Continue" 

### WordPress Login Panel

For accessing the WordPress dashboard:

**URL**: https://mcamaren.42.fr/wp-login.php

** Admin Login Credentials**:
- **Username**: Configured in `.env` file (`WORDPRESS_ADMIN_USER`)
- **Password**: Stored in `secrets/wp_admin_password.txt`

** User Login Credentials**:
- **Username**: Configured in `.env` file (`WORDPRESS_USER`)
- **Password**: Stored in `secrets/wp_user_password.txt`

### Troubleshoot: Cannot Access Website

**Symptoms**: Browser shows "This site can't be reached" or connection timeout.

| Step | Action | Command | Expected Result / Notes |
| :--- | :--- | :--- | :--- |
| **1** | **Check Container Status** | `make ps` | All three services should be status **"Up"**. |
| **2** | **Verify Hosts File** | `cat /etc/hosts \| grep mcamaren` | Should output: `127.0.0.1 mcamaren.42.fr` |
| **3** | **Fix Missing Host** | `echo "127.0.0.1 mcamaren.42.fr" \| sudo tee -a /etc/hosts` | Run this only if Step 2 returns no results. |

---

## 4. Locating and Managing Credentials

### Credential Location


#### 1. **Docker Secrets** (Passwords)
All sensitive credentials are stored in `secrets/` directory, 

```
secrets/
├── db_password.txt          # Database user password
├── db_root_password.txt     # Database root password
├── wordpress_admin_password.txt    # WordPress admin password
└── wordpress_user_password.txt     # WordPress second user password
```


#### 2. **Environment Variables** (Usernames, Emails, URLs)
The rest of credentilas are stored  in `srcs/.env` file:

**Types of Variable**:
- MariaDB Configuration 
- WordPress Database Connection
- Wordpress website configuration 
- Admin user
- Additional user


### 3. **Configuration & Maintenance**

Use the following workflows to update your credentials or environment settings safely.

| Task | Action | Commands | Impact |
| :--- | :--- | :--- | :--- |
| **Change Passwords** | Update secret files & wipe data | `make down`<br>`echo "new_pass" > secrets/wp_pass.txt`<br>`make fclean` then `make` | **High**: Resets the database. All site content will be lost. |
| **Update Settings** | Modify `.env` (emails, domains, etc.) | `make down`<br>`vim srcs/.env`<br>`make up` | **Low**: Containers restart with new environment variables. |

---

### ⚠️ Critical Notes
* **Database Credentials**: Because MariaDB initializes the database upon the first volume creation, changing the `MYSQL_PASSWORD` or `MYSQL_ROOT_PASSWORD` in the secret files requires a `make fclean` to take effect. This will **permanently delete** your current posts and users.
* **Secret Handling**: Always ensure your `secrets/*.txt` files are added to your `.gitignore` to prevent leaking credentials to your repository.

## 5. Checking Service Status

### Quick Status Check

View all running containers:

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

### Viewing Service Logs

## 📋 Log Management

Use these commands to monitor service behavior and troubleshoot issues in real-time.

| Scope | Command | Description |
| :--- | :--- | :--- |
| **Full Stack** | `make logs` | Displays the current log history for all services in the stack. |
| **NGINX Only** | `docker compose -f srcs/compose.yml logs nginx` | Shows specific logs for the web server and SSL requests. |
| **WordPress Only** | `docker compose -f srcs/compose.yml logs wordpress` | Shows PHP-FPM activity and application-level errors. |
| **MariaDB Only** | `docker compose -f srcs/compose.yml logs mariadb` | Shows database initialization and query logs. |

---


If working correctly, you'll see HTML output from WordPress.

### Checking Services Separately


You can verify that each component is functioning correctly by running these diagnostic commands:

| Service | Verification Task | Command | Expected Result |
| :--- | :--- | :--- | :--- |
| **NGINX** | Configuration Test | `docker exec nginx nginx -t` | `syntax is ok` & `test is successful` |
| **WordPress** | PHP-FPM Status | `docker exec wordpress ps aux \| grep php-fpm` | Multiple `php-fpm` processes listed |
| **MariaDB** | Process Check | `docker exec mariadb pgrep -f mysqld` | A numeric Process ID (PID) |
| **MariaDB** | Database Ping | `docker exec mariadb mysqladmin ping -u root -p$(cat secrets/db_root_password.txt)` | `mysqld is alive` |
---

