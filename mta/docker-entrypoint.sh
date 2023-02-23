#!/bin/bash
set -e

### create the tmp files
MAIN=/tmp/main.cf
MASTER=/tmp/master.cf
cp /etc/postfix/main.cf.s ${MAIN}
cp /etc/postfix/master.cf.s ${MASTER}

### Vars handling

# optionals
if [ -z "${POSTFIX_RELAY}" ] ; then
    POSTFIX_RELAY=""
fi
if [ -z "${POSTFIX_MAX_MESSAGESIZE}" ] ; then
    POSTFIX_MAX_MESSAGESIZE=2264924
fi
if [ -z "${POSTFIX_ALWAYS_BCC}" ] ; then
    POSTFIX_ALWAYS_BCC=
fi
if [ -z "${POSTFIX_NATIONAL}" ] ; then
    POSTFIX_NATIONAL=cu
fi
if [ -z "${POSTFIX_SPF_ENABLE}" ] ; then
    ENABLE_SPF=${POSTFIX_SPF_ENABLE}
fi

# mandatory
HOSTNAME=`hostname -f`
SYSADMINS=`echo ${POSTFIX_MAILADMIN} | sed s/"@"/"\\\@"/`
HOSTAD=`echo ${POSTFIX_LDAP_URI} | cut -d "/" -f 3 | cut -d ":" -f 1`

# create the local config file
CFILE=/etc/postfix/config.local
echo "DOMAIN=${POSTFIX_DOMAIN}" > "${CFILE}"
echo "MESSAGESIZE=${POSTFIX_MAX_MESSAGESIZE}" >> "${CFILE}"
echo "LDAPURI=${POSTFIX_LDAP_URI}" >> "${CFILE}"
echo "LDAPSEARCHBASE=${POSTFIX_LDAP_SEARCH_BASE}" >> "${CFILE}"
echo "LDAPBINDUSER=${POSTFIX_LDAP_BINDUSER}" >> "${CFILE}"
echo "LDAPBINDPASSWD=\"${POSTFIX_LDAP_BINDUSER_PASSWD}\"" >> "${CFILE}"
echo "HOSTNAME=${HOSTNAME}" >> "${CFILE}"
echo "RELAY=${POSTFIX_RELAY}" >> "${CFILE}"
echo "ALWAYSBCC=${POSTFIX_ALWAYS_BCC}" >> "${CFILE}"
echo "SYSADMINS=${SYSADMINS}" >> "${CFILE}"
echo "HOSTAD=${HOSTAD}" >> "${CFILE}"
echo "AMAVISHN=${POSTFIX_AMAVIS}" >> "${CFILE}"
AMAVISIP=`host ${POSTFIX_AMAVIS} | awk '/has address/ { print $4 }'`
echo "AMAVISIP=${AMAVISIP}" >> "${CFILE}"
OWN_IP=`ifconfig eth0 | grep inet | awk '{print $2}'`
echo "OWN_IP=${OWN_IP}" >> "${CFILE}"

# config dump
echo "Config file dump:"
cat ${CFILE}

# loading configs
. "${CFILE}"

# get the vars from the file
VARS=`cat "${CFILE}" | cut -d "=" -f 1`

# replace the vars in the folders
for v in `echo "${VARS}" | xargs` ; do
    # get the var content
    CONTp=${!v}

    # escape possible "/" in there
    CONT=`echo ${CONTp//\//\\\\/}`

    sed -i s/"\_${v}\_"/"${CONT}"/g ${MAIN}
    sed -i s/"\_${v}\_"/"${CONT}"/g ${MASTER}

    find "/etc/postfix/ldap" -type f -exec sed s/"\_$v\_"/"${CONT}"/g -i {} \; -print
done

# check for SPF activation
if [ -z "${ENABLE_SPF}" -o "${ENABLE_SPF}" == "no" -o "${ENABLE_SPF}" == "No" -o "${ENABLE_SPF}" == "False" -o "${ENABLE_SPF}" == "false"  ] ; then
    # disable SPF
    sed -i s/"^.*spf.*$"/''/g ${MAIN}

    # notice
    echo "Disabed SPF as requested by the config"
fi

### DNSBL
if [ "${POSTFIX_DNSBL}" == "yes" -o "${POSTFIX_DNSBL}" == "Yes" -o "${POSTFIX_DNSBL}" == "True" -o "${POSTFIX_DNSBL}" == "true" ] ; then
    # notice
    echo "Enabled DNSBL filtering as requested by the config"

    # disable simple smtp
    sed -i s/"^smtp      inet  n       -       y       -       -       smtpd"/"#smtp      inet  n       -       y       -       -       smtpd"/ ${MASTER}

    # enable postscreen, smtpd, dnsblog & tlsproxy
    sed -i s/"^#smtp      inet  n       -       y       -       1       postscreen"/"smtp      inet  n       -       y       -       1       postscreen"/ ${MASTER}
    sed -i s/"^#smtpd     pass  -       -       y       -       -       smtpd"/"smtpd     pass  -       -       y       -       -       smtpd"/ ${MASTER}
    sed -i s/"^#dnsblog   unix  -       -       y       -       0       dnsblog"/"dnsblog   unix  -       -       y       -       0       dnsblog"/ ${MASTER}
    sed -i s/"^#tlsproxy  unix  -       -       y       -       0       tlsproxy"/"tlsproxy  unix  -       -       y       -       0       tlsproxy"/ ${MASTER}
else
    # notice
    echo "Disabled DNSBL filtering as requested by the config"

    sed -i s/"^.*dnsbl.*$"/''/g ${MAIN}

    # enables simple smtp
    sed -i s/"^#smtp      inet  n       -       y       -       -       smtpd"/"smtp      inet  n       -       y       -       -       smtpd"/ ${MASTER}

    # disables postscreen, smtpd, dnsblog & tlsproxy
    sed -i s/"^smtp      inet  n       -       y       -       1       postscreen"/"#smtp      inet  n       -       y       -       1       postscreen"/ ${MASTER}
    sed -i s/"^smtpd     pass  -       -       y       -       -       smtpd"/"#smtpd     pass  -       -       y       -       -       smtpd"/ ${MASTER}
    sed -i s/"^dnsblog   unix  -       -       y       -       0       dnsblog"/"#dnsblog   unix  -       -       y       -       0       dnsblog"/ ${MASTER}
    sed -i s/"^tlsproxy  unix  -       -       y       -       0       tlsproxy"/"#tlsproxy  unix  -       -       y       -       0       tlsproxy"/ ${MASTER}
fi

### DUMP the configuration
cat ${MAIN} > /etc/postfix/main.cf
cat ${MASTER} > /etc/postfix/master.cf

# make postfix happy with premissions
find /etc/postfix -type d -exec chmod 0750 {} \;
find /etc/postfix -type f -exec chmod g-w,o-w {} \;

### Accesory files

# everyone list
if [ "${POSTFIX_EVERYONE}" ] ; then
    echo "EVERYONE list configured at: ${POSTFIX_EVERYONE}"

    FILE=/etc/postfix/aliases/everyone_list_check
    LINE="$POSTFIX_EVERYONE         everyone_list"

    ISTHERE=`cat ${FILE} | grep everyone_list`
    if [ "${ISTHERE}" ] ; then
        sed -i s/"^.*everyone_list.*$"/"${LINE}"/ ${FILE}
    else
        echo "{$LINE}" >> ${FILE}
    fi
fi

# postfix files to make postmap, with full path
PMFILES="/etc/postfix/rules/lista_negra /etc/postfix/rules/everyone_list_check /etc/postfix/aliases/alias_virtuales"
for f in `echo "$PMFILES" | xargs` ; do
    postmap $f
done

ALIASES="/etc/aliases"
rm -f $ALIASES || exit 0
echo "# File modified at provision time, #MailAD" > $ALIASES
echo "postmaster:       root" >> $ALIASES
echo "clamav:		root" >> $ALIASES
echo "amavis:       root" >> $ALIASES
echo "spamasassin:       root" >> $ALIASES
echo "root:     $SYSADMINS" >> $ALIASES
# apply changes
/usr/bin/newaliases

### DC certs for SSL-LDAP use
# get the DC hostname from the ldap var
DC=`echo "${POSTFIX_LDAP_URI}" | cut -d "/" -f 3 | cut -d ":" -f 1 `
echo "Using ${DC}.${DOMAIN} as LDAP Server"

echo "Get & Install of the samba ssl cert for the LDAP connections"
echo | openssl s_client -connect ${DC}:636 2>&1 | sed --quiet '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /etc/ssl/certs/samba.crt
cat /etc/ssl/certs/samba.crt | head -n 3

# install the cert into the LDAP client setting
echo "TLS_CACERT /etc/ssl/certs/samba.crt" >> /etc/ldap/ldap.conf

### escaped domain for the local restrictions on postfix
ESCDOMAIN=${POSTFIX_DOMAIN//./\\\\\\.}
# escaped national or enterprise wide domain
ESCNATIONAL=${POSTFIX_NATIONAL//./\\\\\\.}

# action goes here
sed s/"_ESCDOMAIN_"/"${ESCDOMAIN}"/g -i /etc/postfix/rules/filter_loc
sed s/"_ESCNATIONAL_"/"${ESCNATIONAL}"/g -i /etc/postfix/rules/filter_nat

### dhparms generation
if [ ! -f /certs/RSA2048.pem ] ; then
    echo "Generation of SAFE dhparam, this may take a time, be patient..."
    openssl dhparam -out /certs/RSA2048.pem -5 2048
    chmod 0644 /certs/RSA2048.pem
    echo "dhparam generated!"
else
    echo "DHparam already present, skiping generation!"
fi

# Setup Let's Encript certs
if [[ ! -z "${HOST_FQDN}" ]] && [[ -f "/certs/${HOST_FQDN}.crt" ]] && [[ -f "/certs/${HOST_FQDN}.key" ]>
    echo "Setup Let's Encrypt certs..."
    rm -f "/certs/mail.crt"
    rm -f "/certs/mail.key"
    rm -f "/certs/RSA2048.pem"
    cp "/certs/${HOST_FQDN}.crt" "/certs/mail.crt"
    cp "/certs/${HOST_FQDN}.key" "/certs/mail.key"
    cp "/certs/${HOST_FQDN}.dhparam.pem" "/certs/RSA2048.pem"
fi

# generate a Self-Signed cert/key if not present already on the /cert volume
if [ ! -f /certs/mail.crt -a ! -f /certs/mail.key ] ; then
    # no certs present.
    echo "WARNING! no cert found, generating a Self-Signed cert"

    openssl req -new -x509 -nodes -days 365 \
        -config /etc/postfix/postfix-openssl.cnf \
        -out /certs/mail.crt \
        -keyout /certs/mail.key
    chmod +r /certs/mail.key
else
    echo "SSL certs in place, skipping generation"
fi

### creation of the groups & aliases
/etc/postfix/scripts/groups.sh


if [ "$1" = 'postfix' ]; then
    if [ ! -f /certs/mail.crt -o ! -f /certs/mail.key -o ! -f /certs/RSA2048.pem ] ; then
        echo "Ooops! There is some SSL files missing"
        echo "We need a existing 'RSA2048.pem, mail.crt' & 'mail.key' files in the /certs volume!"
        exit 1
    fi

    # configure instance (populate etc)
    /usr/lib/postfix/configure-instance.sh

    # check postfix is happy (also will fix some things)
    echo "postfix >> Checking Postfix Configuration"
    postfix -v check

    # start postfix in foreground
    exec /usr/sbin/postfix start-fg
fi

exec "$@"
