#!/bin/bash
set -e

if [ ! -f /etc/samba/smb.conf ]; then
    # varcraft
    DOMAIN_REALM=`echo "${SAMBA_DC_DOMAIN}" | cut -d "." -f 1 | tr [:lower:] [:upper:]`

    echo "Provisoning the dommain ${SAMBA_DC_DOMAIN}, ${DOMAIN_REALM}" 
    samba-tool domain provision \
        --domain="${DOMAIN_REALM}" \
        --realm="${SAMBA_DC_DOMAIN}" \
        --adminpass="${SAMBA_DC_ADMIN_PASSWD}" \
        --server-role dc \
        --dns-backend=SAMBA_INTERNAL \
        --use-rfc2307

    # introduce some insecure settings TODO: allow secure LDAP
    sed s/"rfc2307 = yes"/"rfc2307 = yes\n\tallow dns updates = disabled"/ -i /etc/samba/smb.conf
    sed s/"rfc2307 = yes"/"rfc2307 = yes\n\tldap server require strong auth = no"/ -i /etc/samba/smb.conf

    # creating the users's base
    /scaffolding.sh
fi

if [ "$1" = 'samba' ]; then
    exec samba -i < /dev/null
fi

exec "$@"
