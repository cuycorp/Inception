COMPOSE=./srcs/docker-compose.yml

build:
	docker compose -f ${COMPOSE} build