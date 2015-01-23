# Fail fast and fail hard.
set -eo pipefail

APACHE_VERSION=httpd-2.4.12
APACHE_DIR=/srv/www/${APACHE_VERSION}

cd /tmp

export DEBIAN_FRONTEND=noninteractive

echo "LC_ALL=en_US.UTF-8" > /etc/default/locale
echo "LANG=en_US.UTF-8" >> /etc/default/locale
. /etc/default/locale

apt-get update -qq
apt-get upgrade -y -qq

apt-get install -y -qq libapr1 libapr1-dev libaprutil1 libaprutil1-dev

curl --silent --location http://ftp-stud.hs-esslingen.de/pub/Mirrors/ftp.apache.org/dist/httpd/${APACHE_VERSION}.tar.bz2 | tar jx
cd ${APACHE_VERSION}
./configure --prefix=${APACHE_DIR}
make
make install

cd ${APACHE_DIR}
cd ..
tar cjf /vagrant/${APACHE_VERSION}.tar.bz2 ${APACHE_VERSION}
