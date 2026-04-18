# Developer Documentation
Generate: general description of the objetive of this file.

## Setup the environemnt from scratch

### Prerequisites
Generate: Description of the prerequisites needed for this file.

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

### Configuration files


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

> **Note**: `MYSQL_USER` and `WORDPRESS_DB_USER` must match. `MYSQL_DATABASE` and `WORDPRESS_DB_NAME` must also match. Passwords are **not** set here — they come from the `./secrets/` files.c

### Secrets

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





## Build and Launch the project

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

## Commands for managing containers and volumes


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

###  Service Logs

These commands can be used to monitor service behavior and troubleshoot issues in real-time.

| Scope | Command | Description |
| :--- | :--- | :--- |
| **Full Stack** | `make logs` | Displays the current log history for all services in the stack. |
| **NGINX Only** | `docker compose -f srcs/compose.yml logs nginx` | Shows specific logs for the web server and SSL requests. |
| **WordPress Only** | `docker compose -f srcs/compose.yml logs wordpress` | Shows PHP-FPM activity and application-level errors. |
| **MariaDB Only** | `docker compose -f srcs/compose.yml logs mariadb` | Shows database initialization and query logs. |



## Storage of project data 


## Volume  Management

This Inception project uses two volumes that are configured to map to local host directories:


```yaml
volumes:
  wp_data: ## volumen for wordpress data
    driver_opts: 
      type: none                      # mount type
      device: ${HOME}/data/wordpress # host path for wordpress
      o: bind                        # mount option

  db_data: ## volumen for maria db data
    driver_opts:
      type: none
      device: ${HOME}/data/maria-db # host path for wordpress
      o: bind
```


The directory structure for each of the volumes is as follows:

```
/home/mcamaren/data/
├── mariadb/
│   ├── mysql/              # MariaDB system databases
│   ├── wordpress/          # WordPress database
│   ├── ibdata1             # InnoDB data file
│   ├── ib_logfile0         # Transaction log
│   └── ib_logfile1         # Transaction log
└── wordpress/
    ├── wp-admin/           # WordPress admin files
    ├── wp-content/         # Uploads, themes, plugins
    ├── wp-includes/        # Core WordPress files
    ├── wp-config.php       # Configuration file
    ├── wp-login.php        # Login script
    └── index.php           # Home page
```
 The data persitance with the use of Makefile can be summarized as follows:

| Scenario | Database | WordPress Files |
|----------|----------|-----------------|
| `make stop` | keeps data | keeps data |
| `make down` | keeps data | keeps data |
| `make clean` | keeps data | keeps data |
| `make fclean` | deletes data | deletes data |

