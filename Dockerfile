# NOTE: this is a create-test-delete setup. NEVER USE IT IN PRODUCTION.
# This containter purposely violates the "one container = one process" rule
# for the purpose of faster deployment.
#
# Usage: docker build -t edwardspec/demowiki .
# Run with: docker run -p 1234:80 -p 1235:443 edwardspec/demowiki
#

FROM ubuntu:bionic

RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y \
	php7.2 apache2 libapache2-mod-php7.2 \
	php7.2-opcache php7.2-intl php7.2-mbstring php7.2-xml php7.2-mysql \
	nodejs npm composer \
	mariadb-client-10.1 mariadb-server-10.1 \
	memcached imagemagick librsvg2-bin anacron \
	mlocate git patch telnet unzip \
	&& apt clean

# Download Parsoid (this is slow, so we do this in an early layer)
RUN git clone --recurse-submodules -j 5 https://gerrit.wikimedia.org/r/mediawiki/services/parsoid/deploy /opt/parsoid

ARG MEDIAWIKI_BRANCH=REL1_34
RUN if [ "$MEDIAWIKI_BRANCH" = "REL1_31" ]; then ( cd /opt/parsoid && git checkout --recurse-submodules 1cc68445c46759d0149bc831f0330d2229885d87 ) fi

COPY util/build_mediawiki.sh /
ARG MEDIAWIKI_EXTENSIONS="AbuseFilter CheckUser Echo MobileFrontend PageForms VisualEditor"
RUN /build_mediawiki.sh "$MEDIAWIKI_BRANCH" "$MEDIAWIKI_EXTENSIONS" && mv mediawiki /var/www/html/w

COPY apache.conf /etc/apache2/sites-available/000-default.conf
COPY parsoid_config.yaml /opt/parsoid/config.yaml
COPY ExtraLocalSettings.php /var/www/html/w
RUN a2enmod rewrite actions php7.2 alias

EXPOSE 80 433

ARG DBUSER=wiki
ARG MEDIAWIKI_USER="WikiSysop"
ARG MEDIAWIKI_PASSWORD="123456"

RUN service mysql start && service memcached start && \
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
	# Workaround for update bug of Extension:CheckUser:
	&& mysql -D demowiki -u "$DBUSER" -e 'DELETE FROM recentchanges;' \
	&& php maintenance/update.php --quick \
	# Note: install.php couldn't have set the password for WikiSysop (too simple) before ExtraLocalSettings.php (with $wgPasswordPolicy) was appended.
	&& php maintenance/changePassword.php --user "$MEDIAWIKI_USER" --password "$MEDIAWIKI_PASSWORD"

COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]
