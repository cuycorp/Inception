all: setup up

setup:
	mkdir -p $$HOME/data/wordpress
	mkdir -p $$HOME/data/maria-db

up:
	@docker compose -f ./srcs/compose.yml up -d

down:
	@docker compose -f ./srcs/compose.yml down

downv:
	@docker compose -f ./srcs/compose.yml down --volumes

clean:
	@docker compose -f ./srcs/compose.yml down

fclean:
	@docker compose -f ./srcs/compose.yml down -v --rmi all

re: fclean all