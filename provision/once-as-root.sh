#!/usr/bin/env bash

#== Import script args ==

timezone=$(echo "$1")

#== Bash helpers ==

function info {
  echo " "
  echo "--> $1"
  echo " "
}

#== Provision script ==

info "Provision-script user: `whoami`"

info "Allocate swap for MySQL 5.6"
fallocate -l 2048M /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap defaults 0 0' >> /etc/fstab

info "Configure locales"
update-locale LC_ALL="C"
dpkg-reconfigure locales
5106771641
info "Configure timezone"
echo ${timezone} | tee /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

info "Fix TimeZone"
timedatectl set-timezone America/Vancouver
echo "Done!"

info "Prepare root password for MySQL"
debconf-set-selections <<< "mysql-server-5.6 mysql-server/root_password password mypass"
debconf-set-selections <<< "mysql-server-5.6 mysql-server/root_password_again password mypass"
echo "Done!"

info "Update OS software"
apt-get update
apt-get upgrade -y

info "Install additional LAMP software"
add-apt-repository ppa:ondrej/php
apt-get update
apt-get install zip gzip git curl nginx mysql-server apt-get install php7.4-fpm php7.4-cli php7.4-common php7.4-mysql php7.4-curl php7.4-gd php7.4-dev php7.4-mbstring php7.4-bz2 php7.4-json php7.4-tidy php7.4-bcmath php7.4-intl php7.4-xsl php-redis php-memcached php-pear <<< "y"
pecl install xdebug
echo 'zend_extension="'$(find / -name 'xdebug.so')'"' >> /etc/php/7.4/fpm/php.ini
echo 'xdebug.remote_enable = 1' >> /etc/php/7.4/fpm/php.ini
echo 'xdebug.remote_autostart = 0' >> /etc/php/7.4/fpm/php.ini
echo 'xdebug.remote_connect_back=1' >> /etc/php/7.4/fpm/php.ini
#echo 'xdebug.default_enable = 1' >> /etc/php/7.4/fpm/php.ini
#echo 'xdebug.idekey = "netbeans-xdebug"' >> /etc/php/7.4/php.ini
#echo 'xdebug.remote_port = 9000' >> /etc/php/7.4/fpm/php.ini
#echo 'xdebug.remote_handler=dbgp' >> /etc/php/7.4/fpm/php.ini
#echo 'xdebug.remote_host=10.0.2.2' >> /etc/php/7.4/fpm/php.ini

info "Installing Node.JS and NPM"
curl -sL https://deb.nodesource.com/setup_11.x | bash -
apt-get install -y nodejs build-essential
npm install -g bower

info "Configure MySQL"
sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
echo "Done!"

info "Configure PHP-FPM"
sed -i 's/user = www-data/user = vagrant/g' /etc/php/7.4/fpm/pool.d/www.conf
sed -i 's/group = www-data/group = vagrant/g' /etc/php/7.4/fpm/pool.d/www.conf
sed -i 's/owner = www-data/owner = vagrant/g' /etc/php/7.4/fpm/pool.d/www.conf
chown vagrant:vagrant /run/php/php7.4-fpm.sock
echo "Done!"

info "Configure NGINX"
sed -i 's/user www-data/user vagrant/g' /etc/nginx/nginx.conf
echo "Done!"

info "Enabling site configuration"
ln -s /var/www/html/erec/vagrant/nginx/app.conf /etc/nginx/sites-enabled/erec.conf
#ln -s /var/www/html/cps/vagrant/nginx/app.conf /etc/nginx/sites-enabled/cps.conf
echo "Done!"

info "Initailize databases for MySQL"
mysql -uroot -pmypass <<< "CREATE DATABASE IF NOT EXISTS erec"
mysql -uroot -pmypass <<< "CREATE DATABASE IF NOT EXISTS erec_test"
#mysql -uroot <<< "CREATE DATABASE IF NOT EXISTS cps"
#mysql -uroot <<< "CREATE DATABASE IF NOT EXISTS cps_test"

info "Install composer"
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#info "Install Ruby-SASS"
#sudo apt-get -y install ruby2.0 ruby2.0-dev
#sudo gem2.0 install sass
 