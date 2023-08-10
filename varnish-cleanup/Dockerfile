#Deriving the latest base image
FROM python:latest


#Labels as key value pair
LABEL Maintainer="digirati"

RUN pip install pipenv
WORKDIR /usr/app/src
COPY requirements.txt ./
#RUN pipenv lock > requirements.txt
RUN pip install -r requirements.txt

#to COPY the remote file at working directory in container
COPY cleanup_handler.py ./
COPY app ./app
# Now the structure looks like this '/usr/app/src/test.py'


#CMD instruction should be used to run the software
#contained by your image, along with any arguments.

CMD [ "python", "./cleanup_handler.py"]