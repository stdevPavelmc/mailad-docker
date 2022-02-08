# MailAD, docker MailAD...

[Mailad](https://github.com/stdevPavelmc/mailad) is a on-prem solution to deploy fully functional linux mailserver based on Postfix, Dovecot, Amavis, ClamAv, Spamassasin, etc, to get more details use the previous link.

This is the docker version for that solution & a work in progress right now, we have a [telegram group](https://t.me/MailAD_dev) to discuss the development, feel free to join.

**Warning**: This and the other readmes are written on spare time and amost past 2300 local, so may hide typos, syntax errors, etc, remember this is a early alpha code/repo.

## How to test it?

Just setup a valid docker & docker-compose env, clone this repository, move to it's root folder and run this:

```sh
docker-compose up
```

You are done, it's runnig, if you nee more info (and I hope you need it) keep reading.

## Services

To create a realy dynamic setup we split the mailserver in services:

- [**MTA** (Mail Transport Agent)](./mta/) this is the Postfix field, basically the reception and dispatching of mails to and form the mail server/users.
- [**MDA** (Mail Delivery Agent)](./mda/) This is the Dovecot field, this has to do with the users checking his mails from the mailbox, quotas, etc.
- [**Active Directory**](./samba/) As a test, dev or even production Active directory service, MailAD needs a AD-DC to use as user base.
- **AMAVIS** Advanced filtering, it comprises attachments, anti-virus, anti-spam, etc.
- **WebManagement** This is a simple WebManagement interface maintained by the CUJAE team (insert link)

Follow the links for each service to get details for each image.

## Work in progress.

This is a work in progress, it **will** contain bugs at this stage, and it's presented to you in the dev stage to get feedback and only for testing purposed.

## Contributing.

There are many ways to contribute:

- Review this documentation and fix typos, syntax errors, propose better sentences, etc.
- Propose translations for some of the .md files (Any langs, Spanish, German & French are the most commons, but any will work.)
- Test this setup on dev premises, spot and report/suqash bugs, propose new features/fixes, etc.
- Spread the word about it
- Join to the [telegram group](https://t.me/MailAD_dev) and give some feedback/kudos to the dev.
- Buy the dev a coffee/beer/beef/mouse/? see [this link to know how to send money to the dev](https://github.com/stdevPavelmc/mailad/blob/master/CONTRIBUTING.md#direct-money-donations) to keep it going!
