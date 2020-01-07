#!/bin/bash
# NOTE: this is a create-test-delete setup. NEVER USE IT IN PRODUCTION.
#
# This script directly installs everything into the host system (same things as Dockerfile).
# It must be called on Ubuntu 18 (Bionic).
#
# This was made from Dockerfile to investigate an odd performance problem.
#

apt update
DEBIAN_FRONTEND=noninteractive apt install -y \
	php7.2 apache2 php7.2-fpm \
	php7.2-opcache php7.2-intl php7.2-mbstring php7.2-xml php7.2-mysql \
	nodejs npm composer \
	mariadb-client-10.1 mariadb-server-10.1 \
	memcached imagemagick librsvg2-bin anacron \
	mlocate git patch telnet unzip \
	&& apt clean

# Download Parsoid (this is slow, so we do this in an early layer)
git clone --recurse-submodules -j 5 https://gerrit.wikimedia.org/r/mediawiki/services/parsoid/deploy /opt/parsoid

MEDIAWIKI_BRANCH=REL1_34
if [ "$MEDIAWIKI_BRANCH" = "REL1_31" ]; then ( cd /opt/parsoid && git checkout --recurse-submodules 1cc68445c46759d0149bc831f0330d2229885d87 ) fi

MEDIAWIKI_EXTENSIONS="AbuseFilter CheckUser Echo MobileFrontend PageForms VisualEditor"
./util/build_mediawiki.sh "$MEDIAWIKI_BRANCH" "$MEDIAWIKI_EXTENSIONS" && mv mediawiki /var/www/html/w

cp apache.conf /etc/apache2/sites-available/000-default.conf
cp parsoid_config.yaml /opt/parsoid/config.yaml
cp ExtraLocalSettings.php /var/www/html/w
a2enmod rewrite actions php7.2 alias

a2enmod proxy_fcgi setenvif
a2enconf php7.2-fpm

DBUSER=wiki
MEDIAWIKI_USER="WikiSysop"
MEDIAWIKI_PASSWORD="123456"

service mysql start && service memcached start && \
	mysql -e 'DROP DATABASE IF EXISTS demowiki;' && \
	cd /var/www/html/w && php maintenance/install.php demowiki "$MEDIAWIKI_USER" \
		--pass "$MEDIAWIKI_PASSWORD" \
		--dbtype mysql \
		--dbname demowiki \
		--dbuser "$DBUSER" \
		--dbpass "" \
		--scriptpath "/w" \
		--installdbuser root \
	&& /bin/echo -en "\n\nrequire_once __DIR__ . '/includes/DevelopmentSettings.php'; \n require_once __DIR__ . '/ExtraLocalSettings.php';\n" >> ./LocalSettings.php \
	&& php -l ./LocalSettings.php \
	&& mysql -D demowiki -u "$DBUSER" -e 'DELETE FROM recentchanges;' \
	&& php maintenance/update.php --quick \
	&& php maintenance/changePassword.php --user "$MEDIAWIKI_USER" --password "$MEDIAWIKI_PASSWORD"
	&& cd -

./entrypoint.sh
