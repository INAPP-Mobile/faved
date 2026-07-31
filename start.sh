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

echo "=== sites-enabled at start:"
ls -la /etc/apache2/sites-enabled/

# Railway's runtime can inject its own default vhost (e.g. 000-default.conf with
# DocumentRoot /var/www/html) which sorts BEFORE faved.conf and steals requests.
# Purge every site except faved.conf so the app vhost is the only one active.
echo "=== purging non-faved sites:"
for f in /etc/apache2/sites-enabled/*; do
  [ "$(basename "$f")" = "faved.conf" ] && continue
  rm -f "$f"
  echo "removed $f"
done

echo "=== rebinding Apache to PORT=${PORT:-80}:"
LISTEN_PORT="${PORT:-80}"
if [ "$LISTEN_PORT" != "80" ]; then
  sed -i "s/^Listen 80/Listen ${LISTEN_PORT}/" /etc/apache2/ports.conf
  sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${LISTEN_PORT}>/" /etc/apache2/sites-enabled/faved.conf
  echo "ports.conf now: $(grep -E '^Listen' /etc/apache2/ports.conf)"
  echo "vhost now: $(grep -h 'VirtualHost' /etc/apache2/sites-enabled/faved.conf)"
fi

# Suppress AH00558 FQDN noise in configtest/logs.
grep -q '^ServerName ' /etc/apache2/apache2.conf || echo "ServerName localhost" >> /etc/apache2/apache2.conf

echo "=== configtest:"
apache2ctl configtest

echo "=== starting apache2-foreground:"
exec apache2-foreground
