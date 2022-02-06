FROM ubuntu:focal

LABEL maintainer="Pavel Milanes <pavelmc@gmail.com>"
ENV REFRESHED_AT 2022-02-04
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y samba winbind
RUN rm /etc/samba/smb.conf

ADD docker-entrypoint.sh /docker-entrypoint.sh
ADD scaffolding.sh /scaffolding.sh

RUN chmod +x /docker-entrypoint.sh && chmod +x /scaffolding.sh

VOLUME ["/var/lib/samba", "/etc/samba"]

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["samba"]
