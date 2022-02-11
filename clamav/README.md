# ClamAV (anti-virus) solution image

This is the docker image that server the AV scanning to amavis processing

## It's all about ENV vars

See the sample `docker-compose.yml` file, it has almost all you need, but I will explain some details.

- `CLAMAV_PROXY_SERVER`: If you use proxy, this is the hostname/ip, like this: 10.1.2.3
- `CLAMAV_PROXY_PORT`: the port of the proxy server
- `CLAMAV_ALTERNATE_MIRROR`: if you need/want to specify a local/alternate db mirror, this is the hostname (https and a valid cert is needed)

## Important details

- All interaction is via 3310/tcp port
- There is a volume to preserve the AV dabatabase, see the dockerfile/composer
- This image has a built in healthcheck, see the docker-compose.yml file for an example.
