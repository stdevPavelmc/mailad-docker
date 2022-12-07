#!/bin/sh
set -e

if [ ! -f /etc/dovecot/configured ]; then
    # create the local config file
    CFILE=/etc/dovecot/config.local
    echo "DOMAIN=${DOVECOT_DOMAIN}" > "${CFILE}"
    echo "DEFAULT_MAILBOX_SIZE=${DOVECOT_DEFAULT_MAILBOX_SIZE}" >> "${CFILE}"
    echo "LDAPURI=${DOVECOT_LDAP_URI}" >> "${CFILE}"
    echo "LDAPSEARCHBASE=${DOVECOT_LDAP_SEARCH_BASE}" >> "${CFILE}"
    echo "LDAPBINDUSER=${DOVECOT_LDAP_BINDUSER}" >> "${CFILE}"
    echo "LDAPBINDPASSWD=\"${DOVECOT_LDAP_BINDUSER_PASSWD}\"" >> "${CFILE}"

    # config dump
    echo "Config file dump:"
    cat ${CFILE}

    # force creation of sive fodler
    mkdir -p /var/lib/dovecot/sieve/
    echo "Sieve folder created!"

    # create the default sieve filter
    FILE=/var/lib/dovecot/sieve/default.sieve
    echo 'require "fileinto";' > ${FILE}
    echo 'if header :contains "X-Spam-Flag" "YES" {' >> ${FILE}
    echo '    fileinto "Junk";' >> ${FILE}
    echo '}' >> ${FILE}
    echo "Sieve default SPAM filter created"

    # fix ownership
    #chown -R vmail:vmail /var/lib/dovecot

    # compile it
    sievec /var/lib/dovecot/sieve/default.sieve
    echo "Sieve compilation done"

    ## dhparms generation
    if [ ! -f /certs/RSA2048.pem ] ; then
        echo "Generation of SAFE dhparam, this may take a time, be patient..."
        openssl dhparam -out /certs/RSA2048.pem -5 2048
        chmod 0644 /certs/RSA2048.pem
        echo "dhparam generated!"
    else
        echo "DHparam already present, skiping generation!"
    fi

    # get the DC hostname from the ldap var
    DC=`echo "${DOVECOT_LDAP_URI}" | cut -d "/" -f 3 | cut -d ":" -f 1 | tr [:lower:] [:upper:]`
    echo "Using ${DC} as LDAP Server"

    echo "Get & Install of the samba ssl cert for the LDAP connections"
    echo | openssl s_client -connect ${DC}:636 2>&1 | sed --quiet '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /etc/ssl/certs/samba.crt
    cat /etc/ssl/certs/samba.crt | head

    # install the cert into the LDAP client setting
    cat /etc/ldap/ldap.conf | grep -v TLS_CACERT > /tmp/1
    echo "TLS_CACERT /etc/ssl/certs/samba.crt" >> /tmp/1
    cat /tmp/1 > /etc/ldap/ldap.conf

    # Run the configuration
    echo "Config starting"
    /configure.sh

    # create the flag file
    touch /etc/dovecot/configured
    echo "Flag created: container ready!"
fi

if [ "$1" = 'dovecot' ]; then
    if [ ! -f /certs/mail.crt -o ! -f /certs/mail.key -o ! -f /certs/RSA2048.pem ] ; then
        echo "Ooops! There is some SSL files missing"
        echo "We need a valid 'mail.crt' & 'mail.key' files in the /certs volume!"
        exit 1
    fi

    exec /usr/sbin/dovecot -F < /dev/null
fi

exec "$@"
