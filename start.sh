#!/bin/bash
set -e

# Railway runtime wrapper for Faved:
# 1. Fixes AH00534: the base image can end up with a second Apache MPM
#    (mpm_event) symlinked in mods-enabled at runtime; force exactly prefork.
# 2. Rebinds Apache to $PORT: Railway injects PORT (e.g. 8080) and routes the
#    healthcheck/proxy to it, but the image's Apache listens on 80.

echo "=== mods-enabled MPM state at container start:"
ls -la /etc/apache2/mods-enabled/ | grep mpm || echo "(no mpm files)"
echo "=== forcing single MPM (prefork):"
a2dismod mpm_event mpm_worker 2>/dev/null || true
a2enmod mpm_prefork 2>/dev/null || true
ls -la /etc/apache2/mods-enabled/ | grep mpm

echo "=== rebinding Apache to PORT=${PORT:-80}:"
LISTEN_PORT="${PORT:-80}"
if [ "$LISTEN_PORT" != "80" ]; then
  sed -i "s/^Listen 80/Listen ${LISTEN_PORT}/" /etc/apache2/ports.conf
  sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${LISTEN_PORT}>/" /etc/apache2/sites-enabled/faved.conf
  sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${LISTEN_PORT}>/" /etc/apache2/sites-enabled/*.conf
  echo "ports.conf now: $(grep -E '^Listen' /etc/apache2/ports.conf)"
  echo "vhost now: $(grep -h 'VirtualHost' /etc/apache2/sites-enabled/faved.conf)"
fi

echo "=== configtest:"
apache2ctl configtest

echo "=== starting apache2-foreground:"
exec apache2-foreground
