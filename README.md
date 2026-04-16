# README.md

*This project has been created as part of the 42 curriculum by <login>.*

## Description

This project sets up web infrastructure using Docker. It includes three services running in separate containers and managed with Docker Compose.

The goal is to understand containerization, service isolation, and how different components (web server, database, application) interact together.

The stack typically includes:

* Nginx (web server)
* WordPress (application)
* MariaDB (database)

Each service runs in its own container and communicates through a Docker network.

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

## Project Design Choices

### Virtual Machines vs Docker

* Virtual Machines: heavy, include full OS
* Docker: lightweight, faster, shares host OS

Docker was chosen for efficiency and speed.

### Secrets vs Environment Variables

* Environment variables: easy but less secure
* Secrets: safer, stored separately  

Secrets were used for sensitive data like passwords.

### Docker Network vs Host Network

* Host network: Every container is in the same room. There are no internal room numbers. If one container starts playing music on a speaker (Port 80), no other container can use that speaker because there’s only one

* Docker network: Each container is like an individual apartment with its own room number (Internal IP). They can talk to each other in the hallway, but if someone from the outside world wants to visit, they have to go through the "lobby" (the Host) via a specific port you’ve opened.

Docker network was used to allow safe communication between containers.

### Docker Volumes vs Bind Mounts

* Bind mounts: linked to local files
* Volumes: managed by Docker, more portable

Volumes were used for database persistence.

## Resources

* Docker documentation
https://www.youtube.com/watch?v=XcJzOYe3E6M 
https://www.youtube.com/watch?v=SAMPOK_lazw&t=153s

* Docker Compose documentation
https://docs.docker.com/compose/ 

* Nginx official docs
https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/

* WordPress docs
https://learn.wordpress.org/tutorial/introduction-to-wordpress/

* MariaDB docs
https://www.mariadbtutorial.com/ 


### AI Usage

AI was used to:

* Understand Docker concepts
* Debug configuration issues
* Structure the project and documentation

