This Dockerfile creates a non-production demo server with MediaWiki,
which can be used to showcase MediaWiki extensions, etc.

Usage (to have webserver with MediaWiki listening to port 80):
```
docker build -t edwardspec/demowiki .
docker run -p 80:80 edwardspec/demowiki
```

NOTE: this is a create-test-delete setup. NEVER USE IT IN PRODUCTION.
There is no Varnish, no fail2ban, no backups, no persistent storage for images,
default password for WikiSysop is 123456, etc.

Supported --build-arg values:
- MEDIAWIKI_BRANCH (default: REL1_34),
- MEDIAWIKI_USER (default WikiSysop),
- MEDIAWIKI_PASSWORD (default 123456) - please always change it. (!!!)
- MEDIAWIKI_EXTENSIONS (default "AbuseFilter CheckUser Echo MobileFrontend PageForms VisualEditor")

Contents:
- Ubuntu 18 (bionic)
- MediaWiki
- Parsoid
- MariaDB
- Apache
- memcached

The setup is based on the Travis testsuite of Extension:Moderation:
https://github.com/edwardspec/mediawiki-moderation/
