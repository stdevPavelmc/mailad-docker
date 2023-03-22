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

#if dkim signing enabled
if [ ! -z "${AMAVIS_DKIM_SIGNING_DISABLED}" ] ; then
  # check for DKIM domain configuration
  if [[ ! -z "${AMAVIS_DKIM_DOMAIN}" ]] ; then
    echo "Setup DKIM signing"
    echo '$enable_dkim_signing = 1;' >> /etc/amavis/conf.d/22-dkim_signing
    #Generate domain key
    if [[ ! -f "/var/lib/amavis/dkim/${AMAVIS_DKIM_DOMAIN}.pem" ]] ; then
        echo "DKIM key not present for domain ${AMAVIS_DKIM_DOMAIN} ...generating!!!"
        mkdir -p /var/lib/amavis/dkim
        /usr/sbin/amavisd-new genrsa /var/lib/amavis/dkim/${AMAVIS_DKIM_DOMAIN}.pem 1024
        /usr/sbin/amavisd-new showkeys ${AMAVIS_DKIM_DOMAIN} | tee /var/lib/amavis/dkim/${AMAVIS_DKIM_DOMAIN}.dns.txt
    else
        echo "DKIM key alredy present for domain ${AMAVIS_DKIM_DOMAIN} ...skipping generation!!!"
    fi
    echo "dkim_key('${AMAVIS_DKIM_DOMAIN}', 'dkim', '/var/lib/amavis/dkim/${AMAVIS_DKIM_DOMAIN}.pem');" >> /etc/amavis/conf.d/22-dkim_signing
    echo "@dkim_signature_options_bysender_maps = ({ '.' => { ttl => 30*24*3600, c => 'relaxed/simple' }});" >> /etc/amavis/conf.d/22-dkim_signing
    /usr/sbin/amavisd-new showkeys ${AMAVIS_DKIM_DOMAIN} | tee /var/lib/amavis/dkim/${AMAVIS_DKIM_DOMAIN}.dns.txt
    chown -R amavis:amavis /var/lib/amavis/dkim/${AMAVIS_DKIM_DOMAIN}.*
    # ensure a defined end in the file
    echo '1;' >> /etc/amavis/conf.d/22-dkim_signing
  else
      echo  "DKIM signing enabled, but domain was not provided, missing AMAVIS_DKIM_DOMAIN environment variable"
  fi
else
    echo "DKIM signing disabled by default!!!"
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
