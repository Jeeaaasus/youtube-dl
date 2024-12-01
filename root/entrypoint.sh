#!/bin/bash

echo "[startup] Running init scripts..."

for init in $(ls /etc/cont-init.d/); do
  /etc/cont-init.d/$init
done

echo -e "[startup] Finished.\n"

/bin/supervisord -c /etc/supervisor/supervisord.conf
