FROM ubuntu:focal

LABEL maintainer="Pavel Milanes <pavelmc@gmail.com>"
ENV REFRESHED_AT 2022-02-04
ENV DEBIAN_FRONTEND noninteractive

# TODO: REMOVE on PRODUCTION
RUN apt-get update && apt-get install -y nano netcat-openbsd

RUN apt-get update && \
    apt-get install -y \
        postfix \
        postfix-pcre \
        postfix-ldap \
        ldap-utils \
        net-tools \
        bind9-host && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /home/vmail && \
    chown -R 5000:5000 /home/vmail && \
    groupadd -g 5000 vmail && \
    useradd -d /home/vmail -g 5000 -u 5000 vmail

ADD postfix /etc/postfix
RUN chmod +x /etc/postfix/scripts/*

ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

VOLUME ["/certs", "/home/vmail"]

ENTRYPOINT ["/docker-entrypoint.sh"]

# Ports smtp, smtps, submission
EXPOSE 25 465 587

CMD ["postfix"]
