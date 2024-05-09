FROM ubuntu:22.04

LABEL maintainer="Donald Gray <donald.gray@digirati.com>"
LABEL org.opencontainers.image.source=https://github.com/dlcs/dlcs-varnish
LABEL org.opencontainers.image.description="Varnish on Ubuntu, vcl sourced from S3"

RUN apt-get update -y && apt-get install -y varnish python3-pip
RUN pip install awscli

WORKDIR /usr/app/src
COPY varnish-cleanup/requirements.txt ./
RUN pip install -r requirements.txt

COPY start.sh /start.sh
RUN chmod +x /start.sh

COPY varnish-cleanup/cleanup_handler.py ./
COPY varnish-cleanup/app ./app

ENV VARNISH_PORT 80
EXPOSE 80

CMD ["/start.sh"]
