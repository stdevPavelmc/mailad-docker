#!/bin/sh
set -e

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


# create group
create_group()
{
    # $1: Group name & description
    # $2: group OU
    # $3: email address [optional]

    OPT=""
    if [ "${3}" ] ; then
        OPT="--mail-address='${3}'"
    fi
        samba-tool group "add" "${1}" \
            --description="${1}" \
            --groupou="${2}" ${OPT} \
            -U "administrator" \
            --password="${SAMBA_DC_ADMIN_PASSWD}"
}

# create OU function
create_ou()
{
    # $1: full OU name from the base of the LDAP
    # $2: description/Name
    # $3: mail for the associated group [Optional]

    # create the OU
    samba-tool ou create "${1}" --description="${2}"

    # optional mail
    MAIL=""
    if [ "${3}" ] ; then
        MAIL="${3}"
    fi

    # create an associated group
    create_group "${2}" "${1}" "${MAIL}"
}


# get the base OU for the users, is the first level of the domain
SAMBA_LDAP_BASE_OU=`echo ${SAMBA_DC_DOMAIN} | cut -d "." -f 1 | tr [:lower:] [:upper:]`

# Create the ldap link user
samba-tool user create "${SAMBA_LINK_USER}" "${SAMBA_LINK_USER_PASSWORD}" --description="LDAP link user"

# Create the a simple structure in the LDAP
create_ou "OU=${SAMBA_LDAP_BASE_OU}" "Base OU"
create_ou "OU=Sysadmins,OU=${SAMBA_LDAP_BASE_OU}" "Sysadmins" "sysadmins@${SAMBA_DC_DOMAIN}"
create_ou "OU=ItSupport,OU=${SAMBA_LDAP_BASE_OU}" "ItSupport" "it@${SAMBA_DC_DOMAIN}"
create_ou "OU=Unpriv,OU=${SAMBA_LDAP_BASE_OU}" "Unpriv" "dummy@${SAMBA_DC_DOMAIN}"

# Create the mailadmin user
create_user "${SAMBA_MAILADMIN_USER}" "${SAMBA_MAILADMIN_USER_PASSWD}" "MailAdmin" "OfAllThisShit" "OU=Sysadmins"
create_user "niusdy" "N1usdy_" "Niusdania" "Itstaff" "OU=ItSupport"
create_user "liam" "L14m_qwet" "Liam" "Milanes" "OU=Unpriv"
create_user "lisi" "L1sI___" "Lisabel" "Milanes" "OU=Unpriv"

# add users to groups
samba-tool group addmembers "Sysadmins" "${SAMBA_MAILADMIN_USER}"
samba-tool group addmembers "ItSupport" "niusdy"
samba-tool group addmembers "Unpriv" "liam,lisi"

# Create Special access groups
create_ou "OU=MAIL_ACCESS,OU=${SAMBA_LDAP_BASE_OU}" "Mail Access Groups"
create_group "Local_mail" "OU=MAIL_ACCESS,OU=${SAMBA_LDAP_BASE_OU}" "locals@${SAMBA_DC_DOMAIN}"
create_group "National_mail" "OU=MAIL_ACCESS,OU=${SAMBA_LDAP_BASE_OU}" "nationals@${SAMBA_DC_DOMAIN}"
samba-tool group addmembers "Local_mail" "liam"
samba-tool group addmembers "National_mail" "lisi"
