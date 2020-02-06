#!/bin/sh
set -eou pipefail
if [ -z "$(ls -A /var/lib/mysql/)" ]; then
   mysql_install_db --user=nobody --ldata=/var/lib/mysql && \
   /usr/bin/mysqld --user=nobody --datadir=/var/lib/mysql --bootstrap --verbose=0 --skip-networking=0 < /var/tmp/mysql.sql
   rm /var/tmp/mysql.sql
fi
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf