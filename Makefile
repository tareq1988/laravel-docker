# Makefile for Docker Nginx PHP Composer MySQL
# Ref: https://github.com/nanoninja/docker-nginx-php-mysql/blob/master/Makefile

include .env

# MySQL
MYSQL_DUMPS_DIR=data/dumps

help:
	@echo " "
	@echo "usage: make COMMAND"
	@echo ""
	@echo "Commands:"
	@echo "  install             Install the platform"
	@echo "  code-sniff          Check the API with PHP Code Sniffer (PSR2)"
	@echo "  clean               Clean directories for reset"
	@echo "  composer-up         Update PHP dependencies with composer"
	@echo "  docker-start        Create and start containers"
	@echo "  docker-stop         Stop and clear all services"
	@echo "  gen-certs           Generate SSL certificates"
	@echo "  logs                Follow log output"
	@echo "  mysql-dump          Create backup of whole database"
	@echo "  mysql-restore       Restore backup from whole database"
	@echo "  test                Test application"

install:
	@docker-compose build

clean:
	@rm -Rf data/mysql/*
	@rm -Rf data/logs/*
	@rm -Rf data/nginx-cache/*
	@rm -Rf $(MYSQL_DUMPS_DIR)/*
	@rm -Rf src/web/app/uploads/*
	@rm -Rf src/web/app/plugins/*
	@rm -Rf src/web/app/themes/*

composer-install:
	@docker-compose run --rm -v $(shell pwd):/var/www/html php-fpm composer install

composer-up:
	@docker run --rm -v $(shell pwd):/var/www/html php-fpm composer update

docker-start:
	docker-compose up -d

docker-stop:
	docker-compose down -v

docker-ssh-php:
	docker exec -it php-fpm /bin/bash

docker-ssh-nginx:
	docker exec -it webserver /bin/bash

logs:
	@docker-compose logs -f

mysql-dump:
	@mkdir -p $(MYSQL_DUMPS_DIR)
	@docker exec $(shell docker-compose ps -q mariadb) mysqldump --all-databases -u"$(MYSQL_ROOT_USER)" -p"$(MYSQL_ROOT_PASSWORD)" > $(MYSQL_DUMPS_DIR)/db.sql 2>/dev/null
	@make resetOwner

mysql-restore:
	@docker exec -i $(shell docker-compose ps -q mariadb) mysql -u"$(MYSQL_ROOT_USER)" -p"$(MYSQL_ROOT_PASSWORD)" < $(MYSQL_DUMPS_DIR)/db.sql 2>/dev/null

resetOwner:
	@$(shell chown -Rf $(SUDO_USER):$(shell id -g -n $(SUDO_USER)) $(MYSQL_DUMPS_DIR) "$(shell pwd)/etc/ssl" "$(shell pwd)/src/web" 2> /dev/null)

# .PHONY: clean test code-sniff init
