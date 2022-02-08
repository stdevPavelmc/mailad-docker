# Active Directory Service service for mailad

This is a Docker image crafted to start a Active Directory domain controller using samba4 with some scaffolding of some users to test the MailAD service 

## It's all about ENV vars...

See the sample `docker-compose.yml` file, it has almost all you need, but I will explain some details.

- `SAMBA_DC_DOMAIN`: the domain you are provisioning, usualy the same as the mail domain.
- `SAMBA_DC_ADMIN_PASSWD`: no need for comments.
- `SAMBA_LINK_USER`: this is a common user, it's purpose is to give login access to search for valid users and it will reside in the default Users place of the Domain.
- `SAMBA_LINK_USER_PASSWORD`: password for that user.
- `SAMBA_MAILADMIN_USER`: this is the login/email username for the mailadmin real user, like 'pavel' in 'pavel@mailad.cu'.
- `SAMBA_MAILADMIN_USER_PASSWD`: password for that user.

## Important details.

The AD-DC LDAP structure will have the structure stated on the [original document](https://github.com/stdevPavelmc/mailad/blob/master/AD_Requirements.md):

- **Do not change the container name from 'dc'!**
- You will have a OU to hold the user's data
- All users with mail *must be on or below that OU*
- In this docker samba implementation the name of the OU is the first part of the domain in uppercase, like this:
    - MAILAD for mailad.cu
    - CO7WT for co7wt.edu.cu

## This is a test docker image

This image goal is to have a AD-DC to test the MailAD server, it depends on you to provide your AD-DC or use this AD-DC just for MailAD.
