# MailAD, docker MailAD...

[Mailad](https://github.com/stdevPavelmc/mailad) is a on-prem solution to deploy fully functional linux mailserver based on Postfix, Dovecot, Amavis, ClamAv, Spamassasin, etc. For more detail use the previous link.

This is the docker version for that solution & a work in progress right now, we have a [telegram group](https://t.me/MailAD_dev) to discuss the development, feel free to join.

**Warning**: This and the other readmes are written on spare time and amost past 2300 local, so may contain typos, syntax errors, etc, remember this is a early alpha code/repo.

## How to test it?

Just setup a valid docker & docker-compose env, clone this repository, move to it's root folder and run this:

```sh
docker-compose up
```

You are done, it's runnig, if you nee more info (and I hope you need it) keep reading.

## Services

To create a realy dynamic setup we split the mailserver in services:

- **MTA** (Mail Transport Agent) this is the Postfix field, basically the reception and dispatching of mails to and form the mail server/users.
- **MDA** (Mail Delivery Agent) This is the Dovecot field, this has to do with the users checking his mails from the mailbox, quotas, etc.
- **Active Directory** As a test, dev or even production Active directory service, MailAD needs a AD-DC to use as user base.
- **AMAVIS** Advanced filtering, it comprises attachments, anti-virus, anti-spam, etc.
- **WebManagement** This is a simple WebManagement interface maintained by the CUJAE team (insert link)

From this services until now we have the AD, MTA & MDA, we are developing/testing the others in this moment.

# Work in progress.

This is a work in progress, it **will** contain bugs at this stage, and it's presented to you in the dev stage to get feedback and only for testing purposed.
