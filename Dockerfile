FROM ubuntu:20.04

LABEL maintainer="Donald Gray <donald.gray@digirati.com>"
LABEL org.opencontainers.image.source=https://github.com/dlcs/dlcs-varnish
LABEL org.opencontainers.image.description="Varnish on Ubuntu, vcl sourced from S3"

RUN apt-get update -y && apt-get install -y varnish python3-pip
RUN pip install awscli

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENV VARNISH_PORT 80
EXPOSE 80

CMD ["/start.sh"]
