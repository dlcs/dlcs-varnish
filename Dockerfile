FROM ubuntu:20.04

RUN apt-get update -y && apt-get install -y varnish python3-pip
RUN pip install awscli

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENV VARNISH_SIZE 100M
ENV VARNISH_PORT 80
EXPOSE 80

CMD ["/start.sh"]
