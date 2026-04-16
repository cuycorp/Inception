
## Overview

This project provides a website using WordPress, served by Nginx and powered by a MariaDB database.

## Start and Stop

Start:

```bash
make
```

Remove containers:

```bash
make down
```

Remove containers and volumes:

```bash
make downv
```

## Access Services

* Website: [http://localhost](http://localhost)
* Admin panel: [http://localhost/wp-admin](http://localhost/wp-admin)

## Credentials

Credentials are stored in environment variables or Docker secrets.

## Check Services

```bash
docker ps
```

