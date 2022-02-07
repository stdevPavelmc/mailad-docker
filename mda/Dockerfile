FROM ubuntu:focal

LABEL maintainer="Pavel Milanes <pavelmc@gmail.com>"
ENV REFRESHED_AT 2022-02-04
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y \
    sed \
    dovecot-pop3d \
    dovecot-imapd \
    dovecot-ldap \
    dovecot-sieve \
    dovecot-lmtpd \
    dovecot-managesieved

# TODO: REMOVE on PRODUCTION
RUN apt-get install -y nano ldap-utils net-tools

RUN mkdir /home/vmail && \
    chown -R 5000:5000 /home/vmail && \
    groupadd -r postfix && \
    groupadd -g 5000 vmail && \
    useradd -d /home/vmail -g 5000 -u 5000 vmail && \
    useradd -r -d /var/spool/ -g postfix postfix

ADD dovecot/ /etc/dovecot

ADD docker-entrypoint.sh /docker-entrypoint.sh
ADD configure.sh /configure.sh
RUN chmod +x /docker-entrypoint.sh && chmod +x /configure.sh

VOLUME ["/certs", "/home/vmail"]

ENTRYPOINT ["/docker-entrypoint.sh"]

# Ports pop, imap, sieve and sasl
EXPOSE 110 143 993 995 4190 12345


CMD ["dovecot"]
