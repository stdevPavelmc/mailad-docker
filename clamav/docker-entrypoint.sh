#!/bin/bash
set -m

if [ ! -f /etc/clamav/configured ] ; then
    if ! [ -z "${CLAMAV_PROXY_SERVER}" ]; then
        echo "HTTPProxyServer ${CLAMAV_PROXY_SERVER}" >> /etc/clamav/freshclam.conf
    fi

    if ! [ -z "${CLAMAV_PROXY_PORT}" ]; then
        echo "HTTPProxyPort ${CLAMAV_PROXY_PORT}" >> /etc/clamav/freshclam.conf
    fi
    # config alternate mirrors
    if [ ! -z "${CLAMAV_ALTERNATE_MIRROR}" ]; then
        sed -i s/"DatabaseMirror .*$"/""/g /etc/clamav/freshclam.conf
        echo "DatabaseMirror ${CLAMAV_ALTERNATE_MIRROR}" >> /etc/clamav/freshclam.conf
    fi

    touch /etc/clamav/configured
fi

# fix perms if needed 
chown clamav:clamav /var/lib/clamav
chmod -R 0755 /var/lib/clamav/

DB_DIR=$(sed -n 's/^DatabaseDirectory\s\(.*\)\s*$/\1/p' /etc/clamav/freshclam.conf )
DB_DIR=${DB_DIR:-'/var/lib/clamav'}
MAIN_FILE="$DB_DIR/main.cvd"

# start of the magic
freshclam -d &
echo -e "waiting for clam to update..."

until [ -e ${MAIN_FILE} ] ; do
    :
done

echo -e "starting clamd..."
clamd &

# recognize PIDs
pidlist=$(jobs -p)

# initialize latest result var
latest_exit=0

# define shutdown helper
function shutdown() {
    trap "" SIGINT

    for single in $pidlist; do
        if ! kill -0 "$single" 2> /dev/null; then
            wait "$single"
            latest_exit=$?
        fi
    done

    kill "$pidlist" 2> /dev/null
}

# run shutdown
trap shutdown SIGINT
wait -n

# return received result
exit $latest_exit
