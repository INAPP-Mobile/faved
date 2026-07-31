#!/bin/bash
set -e

# Diagnostic + fix for Railway runtime:
# The image ships with exactly one Apache MPM (prefork) enabled, but Railway's
# runtime can end up with a second MPM .load symlink present, which aborts
# startup with AH00534 "More than one MPM loaded". Log the state, force a
# single MPM, then start Apache normally.

echo "=== mods-enabled MPM state at container start:"
ls -la /etc/apache2/mods-enabled/ | grep mpm || echo "(no mpm files)"
echo "=== relevant env:"
env | grep -iE '^(APACHE|PORT|RAILWAY)' | sort || true

echo "=== forcing single MPM (prefork):"
a2dismod mpm_event mpm_worker 2>/dev/null || true
a2enmod mpm_prefork 2>/dev/null || true
ls -la /etc/apache2/mods-enabled/ | grep mpm

echo "=== configtest:"
apache2ctl configtest

echo "=== starting apache2-foreground:"
exec apache2-foreground
