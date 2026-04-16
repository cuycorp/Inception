## Prerequisites

* Docker
* Docker Compose
* Make

## Setup

Clone the repository and ensure configuration files and secrets are correctly set.

## Instructions

### Run the project

```bash
make
```

### Remove containers

```bash
make down
```

### Remove container and volumes

```bash
make downv
```

### Full system reset

```bash
make fclean
```

### Fresh Rebuild

```bash
make re
```

## Data Persistence

* Database data is stored in Docker volumes
* Volumes ensure data is not lost when containers stop

## Project Structure

* srcs/compose.yml: service definitions
* volumes: persistent data
* containers: isolated services
