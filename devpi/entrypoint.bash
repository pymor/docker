#!/bin/bash
DEVPI_PASSWORD=fjre
set -uxe
devpi-init
#((devpi-server --restrict-modify root --host 127.0.0.1 --port 3141) & jobs -p >/var/run/devpi.pid)
devpi-server --restrict-modify root --host 127.0.0.1 --port 3141  & export DEVPI_PID=$!
sleep 6s
devpi use http://localhost:3141
devpi login root --password=''
devpi user -m root password="${DEVPI_PASSWORD}"
devpi index -y -c public bases=root/pypi pypi_whitelist='*'
kill -15 ${DEVPI_PID}

exec devpi-server --restrict-modify root --host 0.0.0.0 --port 3141
