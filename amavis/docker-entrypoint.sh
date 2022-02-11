#!/bin/bash
set -m

# check for the MTA configuration
if [ -z "${AMAVIS_MTA}" ]; then
    echo "Error, you must specify a MTA to forward mail to in the 'AMAVIS_MTA' var"
    exit 1;
fi

# Replace the MTA var
echo "Setting MTA in proper files..."
find "/etc/amavis/" -type f -exec sed -i s/"\_MTA\_"/"${AMVIS_MTA}"/g {} \; -print

# sa updates as a task
(
while true; do
	sa-update -v
	sleep 24h
done
) &

# starting amavis
echo "Starting amavis"
amavisd-new foreground &

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
