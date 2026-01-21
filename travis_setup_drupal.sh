#!/usr/bin/env bash

set -eou pipefail
set -x

export COMPOSER_MEMORY_LIMIT=-1
export COMPOSER_NO_INTERACTION=true

echo "Setup database for Drupal"
mysql -h 127.0.0.1 -P 3306 -u root -e "CREATE USER 'drupal'@'%' IDENTIFIED BY 'drupal';"
mysql -h 127.0.0.1 -P 3306 -u root -e "GRANT ALL PRIVILEGES ON drupal.* TO 'drupal'@'%';"
mysql -h 127.0.0.1 -P 3306 -u root -e "FLUSH PRIVILEGES;"

echo "Install utilities needed for testing"
mkdir /opt/utils
cd /opt/utils
if [ -z "${COMPOSER_PATH:-}" ]; then
  composer require drupal/coder 8.3.13 # 8.3.14 breaks, see https://www.drupal.org/project/coder/issues/3262291 
  composer require sebastian/phpcpd ^6
else
  php -dmemory_limit=-1 $COMPOSER_PATH require drupal/coder 8.3.13 # 8.3.14 breaks, see https://www.drupal.org/project/coder/issues/3262291 
  php -dmemory_limit=-1 $COMPOSER_PATH require sebastian/phpcpd ^6
fi
sudo ln -s /opt/utils/vendor/bin/phpcs /usr/bin/phpcs
sudo ln -s /opt/utils/vendor/bin/phpcpd /usr/bin/phpcpd

if command -v phpenv &> /dev/null; then
    phpenv rehash
else
    echo "phpenv not found, skipping rehash"
fi

phpcs --config-set installed_paths /opt/utils/vendor/drupal/coder/coder_sniffer

echo "Composer install drupal site"
if [ -z "${DRUPAL_VERSION:-}" ]; then
   # Just fail if we don't set a version
   echo "DRUPAL_VERSION is not set, exiting"
   exit 1
fi

mkdir -p /opt/drupal
pushd /opt/drupal
composer create-project "drupal/recommended-project:$DRUPAL_VERSION" .
composer require -W "drupal/core-dev:$DRUPAL_VERSION" drush/drush

echo "Setup Drush"
sudo ln -s /opt/drupal/vendor/bin/drush /usr/bin/drush

if command -v phpenv &> /dev/null; then
    phpenv rehash
else
    echo "phpenv not found, skipping rehash"
fi

echo "Drush setup drupal site"
pushd web
drush si --db-url=mysql://drupal:drupal@127.0.0.1:3306/drupal --yes
drush runserver 127.0.0.1:8282 &
until timeout 5 curl -s 127.0.0.1:8282 -o /dev/null; do sleep 1; done
