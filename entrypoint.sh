#!/bin/sh -ex

echo "127.0.0.1 demowiki.example.com" >>/etc/hosts

service apache2 start
service mysql start
service memcached start
( cd /opt/parsoid && PORT=8142 npm start >parsoid.log & )

echo "Started!"
/usr/bin/tail -n0 -f /var/log/apache2/error.log
