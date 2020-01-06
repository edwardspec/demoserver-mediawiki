This script creates a non-production demo server with MediaWiki,
which can be used to showcase MediaWiki extensions, etc.

The setup is based on the Travis testsuite of Extension:Moderation:
https://github.com/edwardspec/mediawiki-moderation/

NOTE: this is a create-test-delete setup. NEVER USE IT IN PRODUCTION.
There is no Varnish, no fail2ban, no backups, no shared images, etc.

Contents:
- Ubuntu 16 (xenial)
- MediaWiki
- Parsoid
- MariaDB
- Apache
- memcached
