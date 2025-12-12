#!/bin/sh
set -e

# Start supervisor to run Octane
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf