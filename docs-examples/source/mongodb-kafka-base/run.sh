#!/bin/bash

set -e
(
if lsof -Pi :27017 -sTCP:LISTEN -t >/dev/null ; then
    echo "Please terminate the local mongod on 27017"
    exit 1
fi
)
arch=$(uname -m)

# Apple M1 laptops running MongoDB 5.x inside Docker is currently not supported so we check and install latest 4.4 build 
if [[ "${arch}" == "arm64" ]]; then
    export PLATFORM=linux/amd64 && export MDBVERSION="mongo:4.4.14" && export MDBSHELL="/usr/bin/mongo"
else
    export PLATFORM=linux/x86_64 && export MDBVERSION="mongo:latest" && export MDBSHELL="/usr/bin/mongosh"
fi
echo "\nRunning on ${arch} setting platform to ${PLATFORM} and pulling MongoDB Version ${MDBVERSION}"

echo "Starting docker ."
docker-compose up -d --build

sleep 5

echo "\nConfiguring the MongoDB ReplicaSet...\n"
# 5.0 and above we can use mongosh else we use the oild mongo shell
docker-compose exec mongo1 ${MDBSHELL} --eval '''rsconf = { _id : "rs0", members: [ { _id : 0, host : "mongo1:27017", priority: 1.0 }]};
rs.initiate(rsconf);'''

sleep 5
echo "\n\nKafka Connectors status:\n\n"
curl -s "http://localhost:8083/connectors?expand=info&expand=status" | \
           jq '. | to_entries[] | [ .value.info.type, .key, .value.status.connector.state,.value.status.tasks[].state,.value.info.config."connector.class"]|join(":|:")' | \
           column -s : -t| sed 's/\"//g'| sort

echo "\n\nVersion of MongoDB Connector for Apache Kafka installed:\n"
curl --silent http://localhost:8083/connector-plugins | jq -c '.[] | select( .class == "com.mongodb.kafka.connect.MongoSourceConnector" or .class == "com.mongodb.kafka.connect.MongoSinkConnector" )'

echo '''

==============================================================================================================

The following services are running:

MongoDB on 27017
Kafka Broker on 9092
Kafka Zookeeper on 2181
Kafka Connect on 8083

Status of kafka connectors:
sh status.sh

To stop these serivces:
docker-compose-down

To stop and remove the MongoDB database volumes:
docker-compose-down -v

(Optional) A docker image is avaialble which includes MongoSH shell, KafkaCat, and various utilitiies:
docker run --rm --name shell1 --network mongodb-kafka-base_localnet -it robwma/mongokafkatutorial:latest bash

==============================================================================================================
'''
