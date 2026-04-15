mkdir -p $HOME/data/wordpress
mkdir -p $HOME/data/maria-db 

all: up 

up: 
	@docker-compose -f ./srcs/compose.yml up -d

down: 
	@docker-compose -f ./srcs/compose.yml down