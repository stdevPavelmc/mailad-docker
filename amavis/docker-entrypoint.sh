#!/bin/bash
set -m

# check for the MTA configuration
if [ -z "${AMAVIS_MTA}" ]; then
    echo "Error, you must specify a MTA to forward mail to in the 'AMAVIS_MTA' var"
    exit 1;
fi

# Replace the MTA var
echo "Setting MTA in proper files..."
find "/etc/amavis/" -type f -exec sed -i s/"\_MTA\_"/"${AMAVIS_MTA}"/g {} \; -print

SPAM=YES
# spamassasin disabled
if [ ! -z "${AMAVIS_SPAMASSASSIN_DISABLED}" -a "${AMAVIS_SPAMASSASSIN_DISABLED}" == "1" ] ; then
    # disable spamassassin
    sed -i s/"@bypass_spam_checks_maps"/"#@bypass_spam_checks_maps"/ /etc/amavis/conf.d/15-content_filter_mode
    SPAM=NO
    echo "SpamAssassin disabled on request!!!"
fi

# AV disabled
if [ ! -z "${AMAVIS_AV_DISABLED}" -a "${AMAVIS_AV_DISABLED}" == "1" ] ; then
    # disable av
    sed -i s/"@bypass_virus_checks_maps"/"#@bypass_virus_checks_maps"/ /etc/amavis/conf.d/15-content_filter_mode
    echo "AV disabled on request!!!"
fi

# set the ip of the mta
MTA_IP=`perl -MSocket -E "say inet_ntoa(inet_aton('${AMAVIS_MTA}'))"`
echo "MTA IP is: ${MTA_IP}"
echo ${MTA_IP} > /etc/amavis/mta 

# starting amavis
echo "Starting amavis"
rm /var/run/amavis/amavisd.pid 2> /dev/null
/usr/sbin/amavisd-new -u amavis -g amavis -i docker debug #foreground # debug

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
