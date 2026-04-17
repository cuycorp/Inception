# Inception - Developer Documentation

This technical manual details the end-to-end environment setup, including secret management, build procedures via Docker Compose, and strategies for managing persistent data volumes.

---

## 1. Set up environment from scratch

### Software 
### Configuration files and secrets

### Prerequisites

Before setting up the project, ensure your development environment has:

## 🛠️ Prerequisites & Installation

Before initializing the Inception project, ensure your host system meets the following hardware and software requirements.

### System Specifications
| Requirement | Minimum Recommendation | Purpose |
| :--- | :--- | :--- |
| **RAM** | 4GB Available | To support multiple concurrent Docker containers. |
| **Storage** | 10GB Free Space | For Docker images and persistent MariaDB/WordPress data. |
| **Privileges** | `sudo` or `root` | Required for Docker socket access and folder creation. |

### Required Toolchain
| Category | Tools | Installation Command |
| :--- | :--- | :--- |
| **Automation** | `make` | `sudo apt-get install -y make` |
| **Virtualization** | `docker` & `docker-compose` | `sudo apt-get install -y docker.io docker-compose` |
| **Utilities** | `curl`, `wget`, `vim`, `git` | `sudo apt-get install -y curl wget vim git` |

---


EDITAR


### 💡 Quick Setup Tip
After installing Docker, ensure your current user is part of the `docker` group to run commands without `sudo`:
```bash
sudo usermod -aG docker $USER && newgrp docker

#### Docker Setup (Important!)

1. **Add your user to the docker group** (to run docker without sudo):
```bash
sudo usermod -aG docker $USER
newgrp docker
```

2. **Verify Docker installation**:
```bash
docker --version
docker compose version
docker run hello-world
```

### Repository Setup

1. **Clone the project**:
```bash
git clone <repository-url>
cd inception
```

Expected structure:
```
inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/                    # Created by user manually
└── srcs/
    ├── docker-compose.yml
    ├── .env                    # Created by user manually
    └── requirements/
        ├── mariadb/
        ├── nginx/
        └── wordpress/
```

---

## 2. Build and Launch the project

### Step 1: Create Environment Variables File

Create `srcs/.env` with all required variables:

```bash
cat > srcs/.env << 'EOF'
# ===== MariaDB Configuration =====
MYSQL_DATABASE=X
MYSQL_USER=X

# ===== WordPress Database Connection =====
WORDPRESS_DB_NAME=X
WORDPRESS_DB_USER=X
WORDPRESS_DB_HOST=X

# ===== WordPress Site Configuration =====
WORDPRESS_URL=X
WORDPRESS_TITLE=X

WORDPRESS_ADMIN_USER=X
WORDPRESS_ADMIN_EMAIL=X

# ===== WordPress Additional User =====
WORDPRESS_USER=X
WORDPRESS_USER_EMAIL=X

# ===== NGINX Configuration =====
DOMAIN_NAME=X
EOF
```

**Important**: Replace 'X' with your actual login and preferences.

### Step 2: Create Docker Secrets

Docker secrets are mounted as files in `/run/secrets/` inside containers.

```bash
# Create secrets directory
mkdir -p secrets

# Generate secure passwords and save to files
echo "secure_db_password" > secrets/db_password.txt
echo "secure_root_password" > secrets/db_root_password.txt
echo "secure_admin_password" > secrets/wp_admin_password.txt
echo "secure_user_password" > secrets/wp_user_password.txt

# Verify secrets were created
ls -la secrets/
```

### Step 3: Configure /etc/hosts

Add your domain to the hosts file for local DNS resolution:

```bash
# Check if domain already exists
grep your_domain /etc/hosts

# If not, add it
echo "127.0.0.1 your_domain" | sudo tee -a /etc/hosts

# Verify
cat /etc/hosts | grep your_domain
```

### Step 4: Prepare Data Directories

The Makefile creates these automatically, but you can pre-create them:

```bash
# Create data directories
mkdir -p /home/mcamaren/data/mariadb
mkdir -p /home/mcamaren/data/wordpress

# Set permissions
chmod 755 /home/mcamaren/data/mariadb
chmod 755 /home/mcamaren/data/wordpress

# Verify
ls -ld /home/mcamaren/data/*/
```

### Step 5: Add Files to .gitignore

Ensure sensitive files are not committed:

```bash
cat >> .gitignore << 'EOF'
# Sensitive credentials
secrets/
srcs/.env
EOF

git add .gitignore
git commit -m "Add gitignore for sensitive files"
```

---

## 2. Building the Project

### Understanding the Build Process

The Inception project uses:
- **Makefile**: Orchestrates build commands
- **Docker Compose**: Manages multi-container orchestration
- **Dockerfiles**: Define custom images for each service

---

### Build Targets
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

## Managing Containers

### Container Lifecycle

#### View Container Status
```bash
# Using make
make ps

# Using docker compose
docker compose -f srcs/docker-compose.yml ps
```

**Output columns**:
- `CONTAINER ID`: Unique identifier
- `IMAGE`: Docker image used
- `COMMAND`: Command/process running inside the container
- `CREATED`: When the container was created
- `STATUS`: Running/Exited/Restarting
- `PORTS`: Port mappings (host:container)
- `NAMES`: Container name

### Container Inspection

#### Inspect Running Container
```bash
# View container details
docker inspect mariadb
docker inspect wordpress
docker inspect nginx

# View specific field, example:
docker inspect -f '{{.State.Running}}' nginx
docker inspect -f '{{.NetworkSettings.IPAddress}}' wordpress
```

#### Execute Commands in Container
```bash
# Interactive shell
docker exec -it wordpress bash
docker exec -it mariadb bash

# Run MariaDB client inside the container
docker exec -it wordpress bash
mysql -u root -p
db_root_password
SHOW DATABASES;
USE WORDPRESS;
SHOW TABLES;

# Run WordPress CLI command
docker exec -it wordpress bash
wp --allow-root user list
```

#### View Resource Usage
```bash
docker stats
docker stats mariadb wordpress nginx
```

### Network Management

#### View Networks
```bash
docker network ls
```

### Image Management

#### View Images
```bash
docker images
docker images | grep -E "mariadb|wordpress|nginx"
```

#### Build Images
```bash
# Build all images
docker compose -f srcs/docker-compose.yml build

# Build specific image
docker compose -f srcs/docker-compose.yml build nginx

# Build with no cache (forces full rebuild)
docker compose -f srcs/docker-compose.yml build --no-cache
```

#### Remove Images
```bash
# Remove unused images
docker image prune

# Remove specific image
docker rmi inception_mariadb
docker rmi inception_wordpress

# WARNING: Remove all images
docker rmi $(docker images -q)
```

---

## Volume and Data Management

### Understanding Volumes in This Project

This project uses **named volumes** that are configured to map to local host directories (bind mounts):

```yaml
volumes:
  mdb:                          # Named volume
    driver: local
    driver_opts:
      type: none                # Bind mount type
      o: bind                   # Mount option
      device: /home/mcamaren/data/mariadb  # Host path
```

**Key advantages**:
- **Named volumes**: Docker manages the volume lifecycle (listed with `docker volume ls`)
- **Local driver with bind**: Maps directly to host filesystem for easy access and backup
- **Explicit control**: You know exactly where data is stored on the host (`/home/mcamaren/data/`)
- **Easy inspection**: Can browse files directly on host machine

### General Data Directory Structure

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

### Data Persistence Behavior

| Scenario | Database | WordPress Files |
|----------|----------|-----------------|
| `make stop` | ✅ Preserved | ✅ Preserved |
| `make down` | ✅ Preserved | ✅ Preserved |
| `make clean` | ✅ Preserved | ✅ Preserved |
| `make up` (after down) | ✅ Reused | ✅ Reused |
| `make fclean` | ❌ DELETED | ❌ DELETED |
| Container restart | ✅ Preserved | ✅ Preserved |
| Host reboot | ✅ Preserved | ✅ Preserved |

### Managing Volumes

#### View Volume Information
```bash
docker volume ls
docker volume inspect volume_name
```

### Clearing Data (Development)

```bash
# Clear only WordPress files (keep database)
sudo rm -rf /home/mcamaren/data/wordpress/*

# Clear only database (keep WordPress files)
sudo rm -rf /home/mcamaren/data/mariadb/*

# Clear everything
make fclean
```

---

### Common Debug Commands

#### Network Debugging
```bash
# Check IP addresses
docker network inspect network_name
```

#### Database Debugging
```bash
# Connect to MariaDB
docker exec -it mariadb mariadb -u root -p$(cat secrets/db_root_password.txt)

# Inside MariaDB shell
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
SELECT * FROM wp_users;
```

#### WordPress Debugging
```bash
# Check WordPress installation
docker exec wordpress wp --allow-root option get siteurl

# List users
docker exec wordpress wp --allow-root user list
```

### Resource Monitoring

```bash
# Monitor all containers
watch docker stats

# Monitor specific container
docker stats mariadb
```

---
*For end-user documentation, see [USER_DOC.md](USER_DOC.md)*

*For project overview and architecture, see [README.md](README.md)*