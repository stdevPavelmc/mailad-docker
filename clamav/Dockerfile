FROM ubuntu/focal

LABEL maintainer="Pavel Milanes <pavelmc@gmail.com>"
ENV REFRESHED_AT 2022-02-10
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install --no-install-recommends -y -qq \
        clamav-daemon \
        clamav-freshclam \
        libclamunrar9 \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# permission juggling
RUN mkdir /var/run/clamav && \
    chown clamav:clamav /var/run/clamav /var/lib/clamav && \
    chmod 750 /var/run/clamav /var/lib/clamav

COPY clamav/ /etc/clamav/
COPY docker-entrypoint.sh /
COPY check.sh /

RUN chown -R clamav:clamav /etc/clamav /docker-entrypoint.sh /check.sh
RUN chmod +x /docker-entrypoint.sh /check.sh

VOLUME ["/var/lib/clamav"]

EXPOSE 3310

USER clamav

CMD ["/docker-entrypoint.sh"]
