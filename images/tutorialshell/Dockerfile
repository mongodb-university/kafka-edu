FROM ubuntu:latest

RUN apt-get -y update

RUN apt-get -y upgrade

RUN apt-get -y install jq && apt-get -y install python3 && apt-get -y install python3-pip

RUN apt-get -y install curl && apt-get -y install kafkacat

COPY requirements.txt ./

RUN echo "**** installing MongoDB Python Driver ****" && \
    \
    pip3 install --no-cache-dir -r requirements.txt && \
     echo "**** installing MongoDB Shell (Beta) ****" && \
    curl https://downloads.mongodb.com/compass/mongosh_0.7.7_amd64.deb -o mongosh.deb && \
    dpkg --install mongosh.deb

RUN echo 'PS1="\[\e[32m\][\e[mMongoDB Kafka Connector Tutorial\e[32m]\e[m : "' >> ~/.bashrc


