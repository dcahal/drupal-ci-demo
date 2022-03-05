#!/bin/sh

chown --recursive www-data. /var/www/html/web/sites/default/files && \
chmod --recursive 755 /var/www/html/web/sites/default/files && \
chown --recursive www-data. /var/www/html/private && \
chmod --recursive 755 /var/www/html/private &

apache2-foreground