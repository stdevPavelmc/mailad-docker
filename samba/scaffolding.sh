#!/bin/sh
set -e

# create OU function
create_ou()
{
    # $1: full OU name from the base of the LDAP
    # $2: description [optional]

    if [ -z "${2}" ] ; then
        samba-tool ou create "${1}"
        return
    fi

    samba-tool ou create "${1}" --description="${2}"
}

# create users function
create_user()
{
    # $1: username (email user reused)
    # $2: password
    # $3: givenmae
    # $4: surname
    # $5: OU (without the base OU)

    samba-tool user create "${1}" "${2}" \
        --given-name="${3}" \
        --surname="${4}" \
        --mail-address="${1}@${SAMBA_DC_DOMAIN}" \
        --userou="${5},OU=${SAMBA_LDAP_BASE_OU}"
}

# create groups
create_groups()
{
    # $1: Group name
    # $2: Description
    # $3: email address []

    samba-tool group "create" "${1}" \
        --description="${2}" \
        --mail-address="${3}" \
        --groupou="${4}" \
        -U "administrator" \
        --password="${SAMBA_DC_ADMIN_PASSWD}"
}

# get the base OU for the users, is the first level of the domain
SAMBA_LDAP_BASE_OU=`echo ${SAMBA_DC_DOMAIN} | cut -d "." -f 1 | tr [:lower:] [:upper:]`

# Create the ldap link user
samba-tool user create "${SAMBA_LINK_USER}" "${SAMBA_LINK_USER_PASSWORD}" --description="LDAP link user"

# Create the a simple structure in the LDAP
create_ou "OU=${SAMBA_LDAP_BASE_OU}" "Base OU"
create_ou "OU=Sysadmins,OU=${SAMBA_LDAP_BASE_OU}" "Sysadmins"
create_ou "OU=ItSupport,OU=${SAMBA_LDAP_BASE_OU}" "IT's staff"
create_ou "OU=Unpriv,OU=${SAMBA_LDAP_BASE_OU}" "Least privilege users"

# Create the mailadmin user
create_user "${SAMBA_MAILADMIN_USER}" "${SAMBA_MAILADMIN_USER_PASSWD}" "MailAdmin" "OfAllThisShit" "OU=Sysadmins"
create_user "niusdy" "N1usdy_" "Niusdania" "Itstaff" "OU=ItSupport"
create_user "liam" "L14m_qwet" "Liam" "Milanes" "OU=Unpriv"
create_user "lisi" "L1sI___" "Lisabel" "Milanes" "OU=Unpriv"
