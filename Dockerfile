FROM debian:bookworm-slim

LABEL maintainer="Donald Gray <donald.gray@digirati.com>"
LABEL org.opencontainers.image.source=https://github.com/dlcs/dlcs-varnish
LABEL org.opencontainers.image.description="Varnish on Debian, vcl sourced from S3"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get install -y varnish python3-pip
RUN pip3 install --break-system-packages awscli

WORKDIR /usr/app/src
COPY varnish-cleanup/requirements.txt ./
RUN pip3 install --break-system-packages -r requirements.txt

COPY start.sh /start.sh
RUN chmod +x /start.sh

COPY varnish-cleanup/cleanup_handler.py ./
COPY varnish-cleanup/app ./app

ENV VARNISH_PORT=80
EXPOSE 80

CMD ["/start.sh"]
