# Inception
This project has been created as part of the 42 curriculum by mcamaren
## Description
### Goal of the project
Inception is a system administration project that deploys a fully containerized web infrastructure using Docker Compose, orchestrating three interconnected services — NGINX as a reverse proxy, WordPress as a content management system, and MariaDB as a relational database — communicating over a custom Docker network with persistent volumes and Docker secrets for secure credential management. Through this project, core DevOps concepts were developed: containerization, inter-service networking, volume and secret management, TLS encryption, and infrastructure automation with Makefiles.

### Overview
| Service | Role | Purpose |
| :--- | :--- | :--- |
| **NGINX** | Reverse Proxy & Web Server | Acts as the single entry point for all incoming HTTPS traffic (port 443). Handles TLS termination using TLS 1.2/1.3, then forwards PHP requests to the WordPress container via FastCGI (PHP-FPM). |
| **WordPress** | Content Management System | Runs the WordPress application with PHP-FPM (FastCGI Process Manager). Serves the website content and communicates with MariaDB to read and write data. No direct public access — only reachable through NGINX. |
| **MariaDB** | Relational Database | Stores all WordPress data (posts, users, settings, etc.). Accessible only by the WordPress container within the internal Docker network, never exposed to the outside world. |

## Instructions
### Information on installation of software

#### Creating a Virtual Machine with Debian in Oracle VirtualBox

1. **Download the required software:**
   - [Oracle VirtualBox](https://www.virtualbox.org/wiki/Downloads) — install the version for your host OS
   - [Debian ISO](https://www.debian.org/distrib/) — download the latest stable `amd64` netinst image

2. **Create a new virtual machine in VirtualBox:**
   - Open VirtualBox and click **New**
   - Set a name (e.g. `inception`), choose **Linux** as the type and **Debian (64-bit)** as the version
   - Allocate at least **2048 MB** of RAM (4096 MB recommended)
   - Create a virtual hard disk: choose **VDI**, **dynamically allocated**, at least **20 GB**

3. **Configure the VM before starting:**
   - Go to **Settings → Storage** and attach the Debian ISO to the optical drive
   - Go to **Settings → Network** and set Adapter 1 to **Bridged Adapter** (or NAT with port forwarding if preferred)

4. **Install Debian:**
   - Start the VM and boot from the ISO
   - Follow the Debian installer: set language, region, hostname (e.g. `inception`), root password, and create a user
   - Choose a minimal install (no desktop environment required, or install XFCE for GUI access)
   - Install the GRUB bootloader to the virtual disk when prompted

5. **Post-installation setup:**
   - Log in and run: `sudo apt-get update && sudo apt-get upgrade -y`
   - Optionally install a desktop environment for browser access:
     ```bash
     sudo apt-get install -y make xorg xfce4 xfce4-goodies lightdm firefox-esr
     ```
   - Configure `/etc/hosts` to resolve your domain locally:
     ```bash
     echo "127.0.0.1   login.42.fr" | sudo tee -a /etc/hosts
     ```

#### Installing Docker and Docker Compose

1. **Install prerequisites:**
   ```bash
   sudo apt-get install -y ca-certificates curl gnupg lsb-release
   ```

2. **Add Docker's official GPG key and repository:**
   ```bash
   sudo install -m 0755 -d /etc/apt/keyrings
   curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
     https://download.docker.com/linux/debian $(lsb_release -cs) stable" | \
     sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```

3. **Install Docker Engine and Docker Compose:**
   ```bash
   sudo apt-get update
   sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
   ```

4. **Allow your user to run Docker without sudo:**
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

5. **Verify the installation:**
   ```bash
   docker --version
   docker compose version
   ```

### Information on execution

A `Makefile` is used to manage the compilation, startup, and cleanup of the project. It wraps all `docker compose` commands so you only need to remember a few short commands to operate the full stack.

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

### Information on configuration of passwords

Sensitive credentials are stored as plain-text files inside a `./secrets/` folder at the root of the project. These files are mounted into containers as Docker secrets and are **never committed to Git** — make sure the `secrets/` directory is listed in your `.gitignore`.

Create each file manually and write the desired password as its sole content (no quotes, no trailing newline):

```bash
# Create the secrets directory
mkdir -p ./secrets

# Database user password
echo "your_db_password" > ./secrets/db_password.txt

# Database root password
echo "your_db_root_password" > ./secrets/db_root_password.txt

# WordPress admin user password
echo "your_wp_admin_password" > ./secrets/wordpress_admin_password.txt

# WordPress second user password
echo "your_wp_user_password" > ./secrets/wordpress_user_password.txt
```

| File | Secret | Used by |
| :--- | :--- | :--- |
| `./secrets/db_password.txt` | Database user password | MariaDB & WordPress |
| `./secrets/db_root_password.txt` | Database root password | MariaDB only |
| `./secrets/wordpress_admin_password.txt` | WordPress admin password | WordPress |
| `./secrets/wordpress_user_password.txt` | WordPress second user password | WordPress |

> ⚠️ **Important**: Add `secrets/` to your `.gitignore` to avoid exposing credentials.

### Information on configuration of user

Project configuration is managed through a `.env` file located at `srcs/.env`. This file contains non-sensitive settings (usernames, database names, site URLs, etc.). Open the file and replace the example values with your own:

```bash
##############Maria db#############
MYSQL_DATABASE=wordpress
MYSQL_USER=exampleuser

#############Wordpress database connection#############
WORDPRESS_DB_HOST=mariadb:3306
WORDPRESS_DB_USER=exampleuser
WORDPRESS_DB_NAME=wordpress

#############Wordpress website configuration#############
WORDPRESS_URL=https://localhost
WORDPRESS_TITLE=Inception

#############Admin user#############
WORDPRESS_ADMIN_USER=jefe
WORDPRESS_ADMIN_EMAIL=mcamaren@student.42.fr

#############Additional user#############
WORDPRESS_USER=francesca
WORDPRESS_USER_EMAIL=cuycorp@gmail.com
```

**Key variables to customize:**

| Variable | Description | Example |
| :--- | :--- | :--- |
| `MYSQL_DATABASE` | Name of the WordPress database | `wordpress` |
| `MYSQL_USER` | Non-root database user | `wpuser` |
| `WORDPRESS_DB_HOST` | MariaDB service name and port | `mariadb:3306` |
| `WORDPRESS_URL` | Full URL of the WordPress site (HTTPS) | `https://login.42.fr` |
| `WORDPRESS_TITLE` | Title displayed on the website | `My Site` |
| `WORDPRESS_ADMIN_USER` | WordPress administrator username | `admin` |
| `WORDPRESS_ADMIN_EMAIL` | Administrator email address | `admin@example.com` |
| `WORDPRESS_USER` | Second (non-admin) WordPress user | `editor` |
| `WORDPRESS_USER_EMAIL` | Second user email address | `editor@example.com` |

> **Note**: `MYSQL_USER` and `WORDPRESS_DB_USER` must match. `MYSQL_DATABASE` and `WORDPRESS_DB_NAME` must also match. Passwords are **not** set here — they come from the `./secrets/` files.

## Project Description
### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker Containers |
| :--- | :--- | :--- |
| **Definition** | A software emulation of a complete computer, running its own full operating system on top of a hypervisor (e.g. VirtualBox, VMware). | A lightweight, isolated process that shares the host OS kernel, packaged with its own filesystem, libraries, and dependencies using container technology. |
| **Features** | Full OS isolation; supports any OS regardless of host; strong security boundaries; high RAM and disk usage (GBs per VM); slow startup (minutes); low portability due to large image sizes; hypervisor overhead affects performance. | Shares host kernel (no full OS per container); very low resource usage (MBs); near-instant startup (seconds); highly portable via layered images; near-native performance; weaker isolation than VMs but sufficient for most workloads. |

### Secrets vs Environment Variables

| Aspect | Docker Secrets | Environment Variables |
| :--- | :--- | :--- |
| **Definition** | Files containing sensitive data that Docker mounts in-memory at `/run/secrets/` inside the container. They are encrypted in transit and never stored in the container's environment. | Key-value pairs injected into a container's environment at startup, typically via a `.env` file or the `environment:` block in `docker-compose.yml`. |
| **Features** | Not visible via `docker inspect`; only accessible by explicitly designated services; encrypted at rest (in Swarm mode); ideal for passwords, keys, and certificates; can be rotated without rebuilding images. | Visible via `docker inspect` and in process listings; easy to set and override; suitable for non-sensitive configuration such as usernames, URLs, and database names; require container restart to update. |

### Docker Network vs Host Network

| Aspect | Docker Bridge Network | Host Network |
| :--- | :--- | :--- |
| **Definition** | A virtual isolated network created and managed by Docker, in which containers communicate with each other by service name and are only reachable from outside through explicitly published ports. | A network mode where the container shares the host machine's network stack directly, with no isolation between the container and the host's network interfaces. |
| **Features** | Full network isolation between services; built-in DNS resolution by container/service name; only published ports are exposed to the outside; slight performance overhead from the virtual bridge; ideal for microservices with controlled access. | No network isolation; all container ports are directly accessible on the host; no port mapping required; native network performance; riskier security posture; rarely appropriate for multi-service applications. |

### Docker Volumes vs Bind Mounts

| Aspect | Named Volumes | Bind Mounts |
| :--- | :--- | :--- |
| **Definition** | A storage mechanism fully managed by Docker, where data is stored in a Docker-controlled location on the host (typically under `/var/lib/docker/volumes/`). | A direct mapping between a specific path on the host filesystem and a path inside the container, giving the user explicit control over where data is stored. |
| **Features** | Docker manages location and permissions; platform-independent and portable; easy backup with `docker volume` commands; data persists across container restarts; optimized I/O by Docker. | User specifies exact host path; requires the path to exist on the host; may need manual permission configuration; easy to inspect or back up with standard filesystem tools; data location is explicit and predictable; ideal for development or when host-path control is needed. |

## Resources 
### Docker: 
- https://www.youtube.com/watch?v=XcJzOYe3E6M
- https://www.youtube.com/watch?v=SAMPOK_lazw&t=153s
### Docker compose:
- https://www.youtube.com/watch?v=BTXfR76WmCw 
###  Nginx:
- https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/
### Wordpress:
- https://www.geeksforgeeks.org/wordpress/how-to-make-wordpress-website/
### Mariadb:
- https://www.geeksforgeeks.org/dbms/introduction-of-mariadb/
### AI:
- used for troubleshooting and clarifying concepts on the three services and docker compose.

## Author
mcamaren — ecole 42