#!/bin/bash

echo "[startup] Running init scripts..."

scripts_dir="$(mktemp -d)"

# Merge provided and local init scripts, allowing local scripts to override
cp /etc/cont-init.d/* "$scripts_dir"
[ -d /etc/cont-init-local.d ] && cp /etc/cont-init-local.d/* "$scripts_dir"

run-parts --umask $UMASK "$scripts_dir"

rm -rf "$scripts_dir"

echo -e "[startup] Finished.\n"

/bin/supervisord -c /etc/supervisor/supervisord.conf
