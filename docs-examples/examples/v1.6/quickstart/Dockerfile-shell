FROM ubuntu:latest
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get install -y curl; apt-get install -y kafkacat
# install mongosh
RUN curl https://downloads.mongodb.com/compass/mongodb-mongosh_1.0.0_amd64.deb -o mongosh.deb && \
    dpkg --install mongosh.deb
COPY source-connector.json sink-connector.json sink-connector-cdc.json initialize-container.sh /
RUN chmod +x initialize-container.sh

# Modify command prompt
RUN echo 'PS1="\[\e[32m\][\e[mMongoDB Kafka Connector Quick Start\e[32m]\e[m : "' >> ~/.bashrc

# Add welcome text
COPY greeting.sh /
RUN cat greeting.sh >> ~/.bashrc

# Cleanup
RUN rm mongosh.deb
RUN rm greeting.sh
