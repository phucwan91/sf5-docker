.PHONY: site-exec-node site-install-back site-fix-permission site-install site-install-back site-install-front \
site-assets-watch site-assets-build site-cache-clear site-cache-warmup site-cache-refresh site-data-reset \
site-cs-fix site-cs-check js-cs-fix site-lint-twig site-lint-yaml site-composer site-fixture-load \
site-migrate site-unmigrate

INFRA_DIR    = infra
PROJECT_DIR ?= /var/www/html/site

-include $(INFRA_DIR)/docker/Makefile

env ?= dev

define run-in-container
	@if [ ! -z $$(docker-compose ps -q $(2) 2>/dev/null) ]; then \
		docker-compose exec --user $(1) $(2) /bin/sh -c "cd $(PROJECT_DIR) && $(3)"; \
	else \
		$(3); \
	fi
endef

docker-exec-node:
	docker-compose exec --user root node /bin/sh

site-fix-permission:
	docker-compose exec --user root php sh -c "chmod -R 775 $(PROJECT_DIR)/var/*"
	docker-compose exec --user root php sh -c "chown -R www-data:www-data $(PROJECT_DIR)"

site-install:
	make site-install-back
	make site-install-front
	make site-cache-warmup

site-install-back:
	$(call run-in-container,www-data,php,composer install)

site-install-front:
	$(call run-in-container,root,node,yarn install)

site-lint-front:
	$(call run-in-container,root,node,./node_modules/.bin/eslint assets --format=table --color)

site-asset-build:
	$(call run-in-container,root,node,yarn encore ${env})

site-asset-watch:
	$(call run-in-container,root,node,yarn encore ${env} --watch)

site-cache-clear:
	$(call run-in-container,www-data,php,php bin/console cache:clear --env=${env})

site-cache-warmup:
	$(call run-in-container,www-data,php,php bin/console cache:warmup --env=${env})

site-cache-refresh:
	make site-cache-clear
	make site-cache-warmup

site-data-reset:
	$(call run-in-container,www-data,php,php bin/console doctrine:database:drop --force --if-exists --env=${env})
	$(call run-in-container,www-data,php,php bin/console doctrine:database:create --if-not-exists --env=${env})
	make site-migrate
	make site-fixture-load
	make site-cache-refresh

site-unmigrate:
	$(call run-in-container,www-data,php,php bin/console doctrine:migration:migrate first --no-interaction --env=${env})

site-migrate:
	$(call run-in-container,www-data,php,php bin/console doctrine:migration:migrate --no-interaction --env=${env})

site-fixture-load:
	$(call run-in-container,www-data,php,php bin/console hautelook:fixtures:load --no-interaction --env=${env})

site-cs-fix:
	$(call run-in-container,www-data,php,./vendor/bin/php-cs-fixer fix --allow-risky=yes --show-progress=dots --verbose)

site-cs-check:
	$(call run-in-container,www-data,php,./vendor/bin/php-cs-fixer fix --allow-risky=yes --dry-run --diff --verbose)

site-test:
	$(call run-in-container,www-data,php,./vendor/bin/phpunit)

site-composer:
	$(call run-in-container,www-data,php,php -d memory_limit=-1 /usr/local/bin/composer $(TASK))

site-lint-yaml:
	$(call run-in-container,www-data,php,bin/console lint:yaml config)

site-lint-twig:
	$(call run-in-container,www-data,php,bin/console lint:twig templates)
