# Mail Transport Agent (MTA) aka: Postfix image for MailAD

This is the docker image that holds the MTA service, aka: Postfix part for MailAD

## It's all about ENV vars

See the sample `docker-compose.yml` file, it has almost all you need, but I will explain some details.

- `POSTFIX_MAX_MESSAGESIZE`: By default is 2264924 (~2Mb, the formula is like this: 1024 *1024* MB * 1.08) if you don't set it, it will get set to ~2Mb.
- `POSTFIX_REALY`: [Optional] Relay/smart host, only if you are in a internal network, this is the upstream server that you need to send messages to the outer world.
- `POSTFIX_ALWAYS_BCC`: [Optional] Some enterprises rules that all mails must be copied/archived, this is the email mailbox that will hold the background copy carbon. Warning: this mailbox must exist from the very provision or you will get a bounce for **EVERY** mail sent.
- `POSTFIX_NATIONAL`: [Optional] If you want to have some users locked to a country/domain this is the domain to lock on, for example, to have a group of users locked to the .edu.cu domain you must set  this option to `edu.cu` (without the starting dot). If you don't need that feature just don't set this option.
- `POSTFIX_EVERYONE`: [Optional] If you want an automatic list for everyone in the domian, this is it: the full list name with the domain, it will be created and you must check that it not clash with an existing email address.
- `POSTFIX_SPF_ENABLE`: [Optional] Enable the SPF checking, if not set: disabled, to activate set it to one of these: yes, Yes, true, True
- `POSTFIX_DNSBL`: [Optional] Enable DNSBL checking, if not set: disabled, to activate set it to one of these: yes, Yes, true, True
- `POSTFIX_DOMAIN`: Domain for the server
- `POSTFIX_MAILADMIN`: Mail address of the mail administrator, may be a group or list, but must exists, you will get notifications, alerts, etc via this email.
- `POSTFIX_LDAP_URI`: Ldap uri, by now just ldap [not ldaps, WiP to fix this] for example "ldap://dc:389", the `dc` here is the name/ip.container_name of the Domain Controller, and will detected and used in other parts of the config.
- `POSTFIX_LDAP_SEARCH_BASE`: Ldap search base, DN of the ldap tree that point to the OU that holds the user data, for example "OU=MAILAD,DC=mailad,DC=cu"
- `POSTFIX_LDAP_BINDUSER`: Ldap DN to the user that will be used to link the MTA to the Ldap, for example: CN=linux,CN=Users,DC=mailad,DC=cu"
- `POSTFIX_LDAP_BINDUSER_PASSWD`: Password for the above user

## Important details

The AD-DC LDAP structure will have the structure stated on the [original document](https://github.com/stdevPavelmc/mailad/blob/master/AD_Requirements.md):

- **Do not change the container name from 'mta', Squared! other containers on this swarm will relay on that name!**
- If any doubts go to the MailAD official docs to see a more detailed explanation.
