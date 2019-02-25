#!/usr/bin/bash

yum install -y httpd24
yum install -y php71*
yum install -y memcached
yum install -y openssl-*
yum install -y gcc72*

echo 'Creating MongoDB repo'

MONGOPATH="/etc/yum.repos.d/mongodb-org-4.0.repo"

echo "[mongodb-org-4.0]" > $MONGOPATH
echo "name=MongoDB Repository" >> $MONGOPATH
echo "baseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/4.0/x86_64/" >> $MONGOPATH
echo "gpgcheck=1" >> $MONGOPATH
echo "enabled=1" >> $MONGOPATH
echo "gpgkey=https://www.mongodb.org/static/pgp/server-4.0.asc" >> $MONGOPATH

echo 'Installing MongoDB'

yum install -y mongodb*
pecl7 install mongodb
echo ';Added by saseul-origin team ' $(date) >> /etc/php.ini
echo "extension=mongodb.so" >> /etc/php.ini

service httpd start
service memcached start
service mongod start
chkconfig httpd on
chkconfig memcached on
chkconfig mongod on

yum install -y git

cd ~
git clone https://github.com/encedo/php-ed25519-ext.git
cd php-ed25519-ext
phpize
./configure
make
make install

echo "extension=ed25519.so" >> /etc/php.ini

useradd -s /sbin/nologin saseul

groupadd www
usermod -a -G www apache
usermod -a -G www saseul

cd /var

git clone https://github.com/saseul/supervisor.git saseul-origin
chown -Rf saseul:www /var/saseul-origin
sh /var/saseul-origin/bin/installation_aws_linux.sh
sh /var/saseul-origin/bin/saseul_make
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/bin/composer

cd /var/saseul-origin/script
composer install && composer dump-autoload
cd /var/saseul-origin/saseuld
composer install && composer dump-autoload
cd /var/saseul-origin/api
composer install && composer dump-autoload
cd /var/saseul-origin/component
composer install && composer dump-autoload
