#!/bin/bash
set -m

# check for the MTA configuration
if [ -z "${AMAVIS_MTA}" ]; then
    echo "Error, you must specify a MTA to forward mail to in the 'AMAVIS_MTA' var"
    exit 1;
fi

SPAM=NO
# spamassasin enabled
if [ -z "${AMAVIS_SPAMASSASSIN_DISABLED}" ] ; then
    # enable it
    echo '@bypass_spam_checks_maps = ( \%bypass_spam_checks, \@bypass_spam_checks_acl, \$bypass_spam_checks_re); ' >> /etc/amavis/conf.d/15-content_filter_mode
    SPAM=YES
    echo "SpamAssassin Enabled by default!!!"
else
    echo "SpamAssassin Disabled on request!!!"
fi

# AV enabled
if [ -z "${AMAVIS_AV_DISABLED}" ] ; then
    # enable av
    echo '@bypass_virus_checks_maps = ( \%bypass_virus_checks, \@bypass_virus_checks_acl, \$bypass_virus_checks_re);' >> /etc/amavis/conf.d/15-content_filter_mode
    echo "AV Enabled by default!!!"
else
    echo "AV Disabled on request!!!"
fi

# ensure a defined end oin the file
echo '1;' >> /etc/amavis/conf.d/15-content_filter_mode

# starting amavis
echo "Starting amavis"
rm /var/run/amavis/amavisd.pid 2> /dev/null
/usr/sbin/amavisd-new -u amavis -g amavis -i docker foreground # debug

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
