#!/bin/bash

# This script is part of MailAD, see https://github.com/stdevPavelmc/mailad/
# Copyright 2020 Pavel Milanes Costa <pavelmc@gmail.com>
# LICENCE: GPL 3.0 and later  
#
# Goal:
#   - Search and create the groups as aliases in the postfix MTA
#   - You can create a everyone@domain or whatever you like for all the users
#   - You can create instantaneous group aliases if you fill the "Email"
#     property of a group

echo "Updating the groups and aliases info"

# load the conf file
source /etc/postfix/config.local

# check if we need to get the everyone group
if [ -z "$EVERYONE" ] ; then
    # empy result: Fail
    echo "EVERYONE group disabled, skiping..."
    echo "# Everyone list DISABLED in config" > /etc/postfix/aliases/auto_aliases
    echo " " >> /etc/postfix/aliases/auto_aliases
else
    echo "Trying to retrieve all the emails to form the EVERYONE list"
    echo "login into $HOSTAD as $LDAPBINDUSER"

    # LDAP query
    RESULT=`ldapsearch -o ldif-wrap=no -H "$LDAPURI" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" "(&(objectCategory=person)(objectClass=user)(sAMAccountName=*))" mail | grep "mail: " | grep "@$DOMAIN" | awk '{print $2}' | tr '\n' ','`

    if [ "$RESULT" == "" ] ; then
        # empy result: Fail
        echo "Error, something failed..."
        exit 1
    else
        # Success
        echo "Success, $EVERYONE list created"
        echo "# Everyone list" > /etc/postfix/aliases/auto_aliases
        echo "$EVERYONE     $RESULT" >> /etc/postfix/aliases/auto_aliases
        echo " " >> /etc/postfix/aliases/auto_aliases
    fi
fi

# Getting the list of the groups in the search base
TEMP=`mktemp`
ldapsearch -o ldif-wrap=no -H "$LDAPURI" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" "(&(objectClass=group)(mail=*))" dn | grep "^dn:" > $TEMP

declare -a RES
# parsing the group names, as it can be coded in base64 when non default charset is used
while IFS= read -r line ; do
    L=`echo $line | grep '::'`
    if [ -z "$L" ] ; then
        R=`echo $line | cut -d " " -f 2- `
    else
        R=`echo $line | cut -d " " -f 2-  | base64 -d`
    fi

    # aggregate
    RES+=("$R")
done < $TEMP

rm $TEMP

for G in "${RES[@]}"; do
    # search the group dn
    GEM=`ldapsearch -o ldif-wrap=no -H "$LDAPURI" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" "(&(objectClass=group)(distinguishedName=$G))" mail | grep "mail: " | awk '{print $2}'`

    if [ "$GEM" ] ; then
        RESULT=`ldapsearch -o ldif-wrap=no -H "$LDAPURI" -D "$LDAPBINDUSER" -w "$LDAPBINDPASSWD" -b "$LDAPSEARCHBASE" "(&(objectCategory=person)(objectClass=user)(sAMAccountName=*)(memberOf=$G))" mail | grep "mail: " | awk '{print$2}' | tr '\n' ','`

        echo "# Group: $G" >> /etc/postfix/aliases/auto_aliases
        echo "$GEM   $RESULT" >> /etc/postfix/aliases/auto_aliases
        echo " " >> /etc/postfix/aliases/auto_aliases
    fi 
done

# updating postfix about the change
cd /etc/postfix/aliases && postmap auto_aliases

