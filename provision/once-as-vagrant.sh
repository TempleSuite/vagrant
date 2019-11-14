#!/usr/bin/env bash

#== Import script args ==

github_token=$(echo "$1")

#== Bash helpers ==

function info {
  echo " "
  echo "--> $1"
  echo " "
}

#change mysql root password
info "Changing root password"
mysqladmin -u root -pmypass password "adminuser"

#== Provision script ==

info "Provision-script user: `whoami`"

info "Configure composer"
composer config --global github-oauth.github.com ${github_token}
echo "Done!"

info "Install plugins for composer"
composer global require "fxp/composer-asset-plugin:^1.2.0" --no-progress

info "Install codeception"
composer global require "codeception/codeception=2.0.*" "codeception/specify=*" "codeception/verify=*" --no-progress
echo 'export PATH=/home/vagrant/.config/composer/vendor/bin:$PATH' | tee -a /home/vagrant/.profile

info "Cloning erec project from github"
git clone -b dev https://${github_token}@github.com/TempleSuite/erec-yii2.git /var/www/html/erec
info "Done!"

info "EREC"
info "Install project dependencies"
cd /var/www/html/erec
composer --no-progress --prefer-dist install

info "create .env file"
touch /var/www/html/erec/.env
echo "DB_NAME=erec
DB_USERNAME=root
DB_PASSWORD=adminuser
DB_HOST=localhost

ALIAS_EREC=erec.test
YII_ENV=dev
YII_DEBUG=true

BUGSNAG_API_KEY=a8b6d1deb54fb7a74a7a99ee19c17c1d" > /var/www/html/erec/.env

info "Init project"
./init --env=Development --overwrite=n

info "import dev database"
mysql -uroot -padminuser erec < /var/www/html/erec/console/migrations/sqldump/dev_import.sql

info"Down the database before running migrations up"
php yii seed/down <<< "yes"
php yii schema/down <<< "yes"

info "Apply migrations"
php yii schema/up <<< "yes"
php yii seed/up <<< "yes"
php yii db/import dev <<< "no"


#info "Cloning CPS project from github"
#git clone https://${github_token}@github.com/TempleSuite/cps-yii2.git /var/www/html/cps
#info "Done!"

#info "CPS"
#info "Install project dependencies"
#cd /var/www/html/cps
#composer --no-progress --prefer-dist install

#info "Init project"
#./init --env=Development --overwrite=n

#info "Apply migrations"
#php yii migrate/up <<< "yes"

info "Create bash-aliases 'erec' for vagrant user"
echo 'alias erec="cd /var/www/html/erec"' | tee /home/vagrant/.bash_aliases

info "Enabling colorized prompt for guest console"
sed -i "s/#force_color_prompt=yes/force_color_prompt=yes/" /home/vagrant/.bashrc

#install phpMyAdmin
sudo mkdir /var/www/html/phpMyAdmin
sudo chown vagrant:vagrant /var/www/html/phpMyAdmin
tar -xvzf /var/www/html/erec/vagrant/phpMyAdmin/phpMyAdmin-4.9.0.1-english.tar.gz -C /var/www/html/phpMyAdmin
mv /var/www/html/phpMyAdmin/phpMyAdmin-4.9.0.1-english/* /var/www/html/phpMyAdmin
rm -R /var/www/html/phpMyAdmin/phpMyAdmin-4.9.0.1-english
sudo chown -R vagrant:vagrant /var/www/html/phpMyAdmin

sudo service nginx restart
