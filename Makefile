all: setup up


MARIADB_DATA = $(HOME)/data/maria-db
WORDPRESS_DATA = $(HOME)/data/wordpress


setup:
	mkdir -p $$HOME/data/wordpress
	mkdir -p $$HOME/data/maria-db

up:
	@echo "Building and starting containers"
	@docker compose -f ./srcs/docker-compose.yml up -d

down:
	@echo "Stopping and removing containers"
	@docker compose -f ./srcs/docker-compose.yml down

stop:
	@echo "Stopping containers"
	@docker compose -f ./srcs/docker-compose.yml stop

start:
	@echo "Starting containers"
	@docker compose -f ./srcs/docker-compose.yml start

# Clean: Just stops the engine and clears the virtual pipes (volumes/networks)
clean:
	@echo "Stopping containers and removing docker-managed volumes..."
	@docker compose -f ./srcs/docker-compose.yml down -v

# Fclean: The 'Full' wipe. Stops first, then erases the images and physical data.
fclean: clean
	@echo "Removing all images and physical data folders..."
	@docker compose -f ./srcs/docker-compose.yml down -v --rmi all
	@sudo rm -rf $(MARIADB_DATA) $(WORDPRESS_DATA)
	
re: fclean all


logs:
	@docker compose -f ./srcs/docker-compose.yml logs 

ps:
	@docker compose -f ./srcs/docker-compose.yml ps