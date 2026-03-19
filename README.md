# Inception

*This project has been created as part of the 42 curriculum by mcamaren.*

---

# Inception

## Description

<!-- Briefly present the project: what it is, what it does, and what its goal is. -->

Inception is a system administration project from the 42 curriculum. Its goal is to broaden knowledge of system administration by using **Docker** to virtualize several services inside a personal virtual machine. Each service runs in a dedicated container, built from scratch using custom Dockerfiles based on either Alpine or Debian. No pre-built images from Docker Hub are allowed (except for the base OS images).

### Project Overview

<!-- Describe the services you are deploying and how they interact. -->

The project sets up a small infrastructure composed of different services under specific rules, all orchestrated with **Docker Compose**. The services included are:

- **NGINX** — acts as the sole entry point, configured with TLS (TLSv1.2/1.3 only)
- **WordPress + php-fpm** — the web application, connected to the database
- **MariaDB** — the database backend for WordPress

> Additional services (bonus): <!-- list any bonus services here if applicable -->

### Docker & Design Choices

#### Docker vs Virtual Machines

| | Docker | Virtual Machine |
|---|---|---|
| **Isolation** | Process-level (shares host kernel) | Full OS-level isolation |
| **Resource usage** | Lightweight, shares host resources | Heavy, requires dedicated RAM/CPU/disk |
| **Startup time** | Seconds | Minutes |
| **Portability** | Highly portable via images | Less portable, hardware-dependent |
| **Use case** | Microservices, CI/CD, reproducible envs | Full OS simulation, strong isolation needs |

Docker is used in this project because it allows each service to be isolated, reproducible, and lightweight, without the overhead of running multiple full virtual machines.

#### Secrets vs Environment Variables

| | Docker Secrets | Environment Variables |
|---|---|---|
| **Storage** | Stored as files in memory (tmpfs), not exposed in `inspect` | Visible in `docker inspect`, process lists, and logs |
| **Security** | Designed for sensitive data (passwords, tokens) | Convenient but not secure for secrets |
| **Scope** | Only available to services that explicitly declare them | Available to all processes in the container |
| **Swarm required** | Native secrets require Swarm; workarounds exist for Compose | Work natively in both Compose and standalone Docker |

In this project, sensitive information such as database passwords and credentials are managed using <!-- secrets / .env files — specify your choice and justify it -->.

#### Docker Network vs Host Network

| | Docker Network (bridge) | Host Network |
|---|---|---|
| **Isolation** | Containers communicate via virtual network, isolated from host | Container shares the host's network stack directly |
| **Security** | Better isolation between services and from the host | No network isolation; ports are exposed on the host directly |
| **Port mapping** | Explicit port publishing required | No port mapping needed |
| **Use case** | Multi-container apps needing controlled communication | Performance-critical apps or when host networking is required |

This project uses a **custom Docker bridge network** so that all containers can communicate with each other by service name (DNS resolution), while remaining isolated from the host except through explicitly published ports (443 for NGINX).

#### Docker Volumes vs Bind Mounts

| | Docker Volumes | Bind Mounts |
|---|---|---|
| **Managed by** | Docker daemon | Host filesystem (user-defined path) |
| **Portability** | Portable; Docker manages the path | Host path must exist and match |
| **Performance** | Optimized for Docker | Can be faster for development (direct file access) |
| **Use case** | Persistent data in production | Development (live code reload), config injection |
| **Backup** | Via `docker volume` commands | Direct access to host filesystem |

This project uses **named Docker volumes** to persist the WordPress database (MariaDB) and WordPress files, ensuring data survives container restarts and rebuilds.

### Sources Included

<!-- List all custom Dockerfiles and configuration files included in the project. -->

```
srcs/
├── docker-compose.yml
├── .env
└── requirements/
    ├── nginx/
    │   ├── Dockerfile
    │   └── conf/
    ├── wordpress/
    │   ├── Dockerfile
    │   └── conf/
    └── mariadb/
        ├── Dockerfile
        └── conf/
```

---

## Instructions

### Prerequisites

- A Linux-based host (or VM) with **Docker** and **Docker Compose** installed
- `make` utility available
- Your domain name set to `mcamaren.42.fr` pointing to `127.0.0.1` in `/etc/hosts`

```bash
# Add to /etc/hosts
127.0.0.1   mcamaren.42.fr
```

### Installation & Launch

```bash
# Clone the repository
git clone <repo-url>
cd inception

# Build and start all services
make

# Stop all services
make down

# Clean containers, volumes, and built images
make fclean

# Rebuild everything from scratch
make re
```

### Environment Configuration

Copy the example environment file and fill in the required values:

```bash
cp srcs/.env.example srcs/.env
# Edit srcs/.env with your credentials
```

Required variables:

```env
# Domain
DOMAIN_NAME=<login>.42.fr

# MariaDB
MYSQL_DATABASE=wordpress
MYSQL_USER=
MYSQL_PASSWORD=
MYSQL_ROOT_PASSWORD=

# WordPress
WP_TITLE=
WP_ADMIN_USER=
WP_ADMIN_PASSWORD=
WP_ADMIN_EMAIL=
WP_USER=
WP_USER_PASSWORD=
WP_USER_EMAIL=
```

### Accessing the Application

Once running, the WordPress site is accessible at:

```
https://<login>.42.fr
```

> Note: A self-signed TLS certificate is used. You may need to accept the browser security warning.

---

## Resources

### Documentation

- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/compose-file/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [WordPress CLI documentation](https://developer.wordpress.org/cli/commands/)
- [OpenSSL documentation](https://www.openssl.org/docs/)

### Articles & Tutorials

- [Docker networking overview](https://docs.docker.com/network/)
- [Docker volumes and storage](https://docs.docker.com/storage/volumes/)
- [Docker secrets management](https://docs.docker.com/engine/swarm/secrets/)
- [Understanding TLS/SSL](https://www.cloudflare.com/learning/ssl/what-is-tls/)
- [WordPress with Nginx and php-fpm](https://www.nginx.com/resources/wiki/start/topics/recipes/wordpress/)

### AI Usage

<!-- Describe honestly how AI was used in this project. -->

AI tools (such as ChatGPT, Claude, GitHub Copilot, etc.) were used in this project for the following tasks:

- **Debugging** — Identifying misconfigurations in Dockerfiles and Docker Compose services
- **Documentation** — Drafting and structuring this README
- **Understanding concepts** — Clarifying differences between Docker volumes vs bind mounts, secrets vs environment variables, and networking modes
- <!-- Add any other specific uses -->

> AI was not used to generate the core infrastructure code or Dockerfiles directly. All service configurations were written and reviewed manually to ensure understanding of each component.
