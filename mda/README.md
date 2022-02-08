# Mail Delivery Agent (MDA) aka: Dovecot service for mailad

This is the docker image that holds the MDA service, aka: Dovecot part for MailAD

## It's all about ENV vars

See the sample `docker-compose.yml` file, it has almost all you need, but I will explain some details.

- `DOVECOT_DOMAIN`: Domain for the server
- `DOVECOT_LDAP_URI`: Ldap uri, by now just ldap [not ldaps, WiP to fix this] for example "ldap://dc:389", the `dc` here is the name/ip.container_name of the Domain Controller, and will detected and used in other parts of the config.
- `DOVECOT_LDAP_SEARCH_BASE`: Ldap search base, DN of the ldap tree that point to the OU that holds the user data, for example "OU=MAILAD,DC=mailad,DC=cu"
- `DOVECOT_LDAP_BINDUSER`: Ldap DN to the user that will be used to link the MTA to the Ldap, for example: CN=linux,CN=Users,DC=mailad,DC=cu"
- `DOVECOT_LDAP_BINDUSER_PASSWD`: Password for the above user

## Important details

The AD-DC LDAP structure will have the structure stated on the [original document](https://github.com/stdevPavelmc/mailad/blob/master/AD_Requirements.md):

- **Do not change the container name from 'mda', Squared! other containers on this swarm will relay on that name!**
- If any doubts go to the MailAD official docs to see a more detailed explanation.
