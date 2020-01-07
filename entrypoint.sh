#!/bin/sh -ex

echo "127.0.0.1 demowiki.example.com" >>/etc/hosts

( cd /opt/parsoid && PORT=8142 npm start >parsoid.log & )

service apache2 restart
service mysql restart
service memcached restart

echo "Started!"
/usr/bin/tail -n0 -f /var/log/apache2/error.log
