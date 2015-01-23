# Fail fast and fail hard.
set -eo pipefail

PHP_VERSION=$1

PHP_MIRROR=de1.php.net
PHP_DIR=/srv/www/${PHP_VERSION}

mkdir -p ${PHP_DIR}
cd /tmp

if [ ! -d ${PHP_VERSION} ]; then
	curl --silent --location http://${PHP_MIRROR}/get/${PHP_VERSION}.tar.bz2/from/this/mirror | tar -jx
fi

cd ${PHP_VERSION}/
export EXTENSION_DIR=${PHP_DIR}/lib/php/extensions
export LD_LIBRARY_PATH=${PHP_DIR}
./configure -q \
--prefix=${PHP_DIR} \
--disable-debug \
--disable-rpath \
--disable-static \
--enable-bcmath \
--enable-calendar \
--enable-exif \
--enable-ftp \
--enable-fpm \
--enable-gd-native-ttf \
--enable-intl=shared \
--enable-mbstring \
--enable-opcache \
--enable-pdo=shared \
--enable-shmop \
--enable-soap \
--enable-sockets \
--enable-wddx \
--enable-zip \
--with-bz2=shared \
--with-config-file-path=${PHP_DIR}/etc \
--with-config-file-scan-dir=${PHP_DIR}/etc/conf.d \
--with-curl=shared \
--with-freetype-dir=shared \
--with-gd=shared \
--with-gettext=shared \
--with-jpeg-dir=shared \
--with-mcrypt=shared \
--with-mssql=shared \
--with-mysql=shared \
--with-mysqli=shared \
--with-openssl=shared \
--with-pdo-dblib=shared \
--with-pdo-mysql=shared \
--with-pdo-pgsql=shared \
--with-pdo-sqlite=shared \
--with-pgsql=shared \
--with-png-dir=shared \
--with-readline=shared \
--with-regex=php \
--with-sqlite3=shared \
--with-xmlrpc=shared \
--with-xsl=shared \
--with-zlib=shared \

# I think these are not necessary
#--with-apxs2=/usr/bin/apxs2 \
#--build=x86_64-linux-gnu \
#--host=x86_64-linux-gnu \
#--sysconfdir=/etc \
#--localstatedir=/var \
#--mandir=/usr/share/man \
#--with-pic \
#--with-layout=GNU \
#--with-pear=/usr/share/php \
#--enable-sysvsem \
#--enable-sysvshm \
#--enable-sysvmsg \
#--enable-ctype \
#--with-db4 \
#--with-qdbm=/usr \
#--without-gdbm \
#--with-iconv \
#--with-onig=/usr \
#--with-pcre-regex=/usr \
#--with-libxml-dir=/usr \
#--with-kerberos=/usr \
#--with-openssl=/usr \
#--with-mhash=yes \
#--with-system-tzdata \
#--with-mysql-sock=/var/run/mysqld/mysqld.sock \
#--without-mm \
#--with-enchant=shared,/usr \
#--with-zlib-dir=/usr \
#--with-gd=shared,/usr \
#--with-gmp=shared,/usr \
#--with-xpm-dir=shared,/usr/X11R6 \
#--with-imap=shared,/usr \
#--with-imap-ssl \
#--without-t1lib \
#--with-ldap=shared,/usr \
#--with-ldap-sasl=/usr \
#--with-pspell=shared,/usr \
#--with-unixODBC=shared,/usr \
#--with-recode=shared,/usr \
#--with-snmp=shared,/usr \
#--with-tidy=shared,/usr \

make -s
#make test
make -s install

mkdir -p ${PHP_DIR}/etc/conf.d

cd ..

/srv/www/${PHP_VERSION}/bin/pear channel-update pear.php.net
/srv/www/${PHP_VERSION}/bin/pear install channel://pear.php.net/Net_URL2-0.3.1 || true
/srv/www/${PHP_VERSION}/bin/pear install channel://pear.php.net/HTTP_Request2-0.5.2 || true

printf "\n" | /srv/www/php5/bin/pecl install mongo || true
/srv/www/${PHP_VERSION}/bin/pecl install oauth || true
printf "\n" | /srv/www/php5/bin/pecl install imagick || true
/srv/www/${PHP_VERSION}/bin/pecl install amqp || true

git clone https://github.com/cloudControl/php-memcached.git || true
cd php-memcached
/srv/www/${PHP_VERSION}/bin/phpize
./configure -q --with-php-config=/srv/www/${PHP_VERSION}/bin/php-config 
make -s
make -s install
cd ..

cd ${PHP_DIR}
cd ..
tar cjf /vagrant/${PHP_VERSION}.tar.bz2 ${PHP_VERSION}

#s3cmd put /vagrant/${PHP_VERSION}.tar.bz2 s3://packages.devcctrl.com/buildpack-php/

