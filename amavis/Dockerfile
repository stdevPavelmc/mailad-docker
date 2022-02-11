FROM ubuntu:focal

LABEL maintainer="Pavel Milanes <pavelmc@gmail.com>"
ENV REFRESHED_AT 2022-02-10
ENV DEBIAN_FRONTEND noninteractive


RUN apt-get update && \
    apt-get install -y \
        amavisd-new \
        p7zip-full \
        unrar-free \
        cabextract \
        spamassassin \
        gpg \
        netcat-openbsd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY amavis/ /etc/amavis/
COPY check.sh /
COPY docker-entrypoint.sh /

RUN sa-update -vD

RUN chmod +x /docker-entrypoint.sh /check.sh

VOLUME ["/var/lib/amavis", "/var/lib/spamassassin"]

EXPOSE 10024

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["amavis"]
