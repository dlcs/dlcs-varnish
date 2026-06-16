#Deriving the latest base image
FROM python:latest


#Labels as key value pair
LABEL Maintainer="digirati"
LABEL org.opencontainers.image.source=https://github.com/dlcs/dlcs-varnish-cleanup
LABEL org.opencontainers.image.description="Performs bans on varnish"

RUN pip install pipenv
WORKDIR /usr/app/src
COPY requirements.txt ./
RUN pip install -r requirements.txt

COPY cleanup_handler.py ./
COPY app ./app

CMD [ "python", "./cleanup_handler.py"]