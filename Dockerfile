FROM ubuntu

RUN apt-get update -y && apt-get install -y varnish python-pip
RUN pip install awscli

ADD start.sh /start.sh
RUN chmod +x /start.sh

ENV VARNISH_PORT 80
EXPOSE 80

CMD ["/start.sh"]

