#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
NAME='myproject'
PASSWORD='rootpass'

# update / upgrade
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get -y update
sudo apt-get -y upgrade

# install apache 2.5 and php 5.5
sudo apt-get install -y libapache2-mod-php5.6
sudo apt-get install -y php5.6-mbsting php5.6-zip php5.6-curl php5.6-gd php5.6-intl php-pear php5.6-imagick php5.6-imap php5.6-mcrypt php5.6-pspell php5.6-recode php5.6-sqlite php5.6-tidy php5.6-xmlrpc php5.6-xsl

# install mysql and give password to installer
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
sudo apt-get -y install mysql-server
sudo apt-get -y install php5.6-mysql

# install phpmyadmin and give password(s) to installer
#for simplicity I'm using the same password for mysql and phpmyadmin
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get -y install phpmyadmin

# setup hosts file
echo "<VirtualHost *:80>" >> /etc/apache2/sites-available/000-default.conf
echo "  ServerName ${NAME}.ga" >> /etc/apache2/sites-available/000-default.conf
echo "  ServerAdmin admin@${NAME}.ga" >> /etc/apache2/sites-available/000-default.conf
echo "  <Directory />" >> /etc/apache2/sites-available/000-default.conf
echo "      Options Indexes FollowSymLinks" >> /etc/apache2/sites-available/000-default.conf
echo "      AllowOverride all" >> /etc/apache2/sites-available/000-default.conf
echo "      Require all granted" >> /etc/apache2/sites-available/000-default.conf
echo "  </Directory>" >> /etc/apache2/sites-available/000-default.conf
echo "  DocumentRoot /var/www/myproject/" >> /etc/apache2/sites-available/000-default.conf
echo "  ErrorLog ${APACHE_LOG_DIR}/${NAME}_error.log" >> /etc/apache2/sites-available/000-default.conf
echo "  CustomLog ${APACHE_LOG_DIR}/${NAME}_access.log combined" >> /etc/apache2/sites-available/000-default.conf
echo "  Include conf-available/serve-cgi-bin.conf" >> /etc/apache2/sites-available/000-default.conf
echo "</VirtualHost>" >> /etc/apache2/sites-available/000-default.conf

mysqladmin -uroot -p${PASSWORD} create ${NAME}

# enable mod_rewrite
sudo a2enmod rewrite

# restart apache
service apache2 restart

# install git
sudo apt-get -y install git
sudo apt-get -y install curl

# install Composer
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

composer global require "fxp/composer-asset-plugin:^1.3.1"
composer global require "codeception/codeception=*"
composer global require "codeception/specify=*"
composer global require "codeception/verify=*"
sudo ln -s /home/vagrant/.config/composer/vendor/bin/codecept /usr/local/bin/codecept


curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install -y xvfb
sudo apt-get install -y htop
sudo apt-get install -y redis-server
sudo apt-get install -y unzip
sudo apt-get install -y vim
sudo apt-get install -y mc
sudo apt-get install -y chromium-browser
sudo apt-get install -y gconf2

sudo add-apt-repository ppa:webupd8team/java -y
sudo apt-get update -y
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
sudo apt-get install oracle-java8-installer -y

sudo npm install -g codeceptjs
sudo npm install -g selenium-standalone@latest
sudo selenium-standalone install
sudo npm install -g webdriverio
sudo npm install -g gulp

echo "127.0.0.1    ${NAME}.ga" >> /etc/hosts
