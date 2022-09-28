#!/bin/bash

set -e
(
if lsof -Pi :27017 -sTCP:LISTEN -t >/dev/null ; then
    echo "Please terminate the local mongod process running on port 27017"
    exit 1
fi
)

export MDBVERSION="mongo:6.0.1"
export MDBSHELL="/usr/bin/mongosh"

echo "\nPulling MongoDB Version ${MDBVERSION}"

echo "Starting docker ."
docker-compose up -d --build

sleep 5

echo "\nConfiguring the MongoDB replica set...\n"

docker-compose exec mongo1 ${MDBSHELL} --eval '''rsconf = { _id : "rs0", members: [ { _id : 0, host : "mongo1:27017", priority: 1.0 }]};
rs.initiate(rsconf);'''

sleep 5

echo "\n\nKafka Connectors status:\n\n"
curl -s "http://localhost:8083/connectors?expand=info&expand=status" | \
           jq '. | to_entries[] | [ .value.info.type, .key, .value.status.connector.state,.value.status.tasks[].state,.value.info.config."connector.class"]|join(":|:")' | \
           column -s : -t| sed 's/\"//g'| sort

echo "\n\nMongoDB Connector for Apache Kafka version installed:\n"
curl --silent http://localhost:8083/connector-plugins | jq -c '.[] | select( .class == "com.mongodb.kafka.connect.MongoSourceConnector" or .class == "com.mongodb.kafka.connect.MongoSinkConnector" )'

echo '''

==============================================================================================================

The following services are running:

MongoDB on 27017
Kafka Broker on 9092
Kafka Zookeeper on 2181
Kafka Connect on 8083

To see the status of the Kafka connectors:
sh status.sh

To stop these serivces:
docker-compose-down

To stop and remove the MongoDB database volumes:
docker-compose-down -v

(Optional) A docker image is avaialble which includes MongoSH shell, KafkaCat, and various utilitiies:
docker run --rm --name shell1 --network mongodb-kafka-base_localnet -it robwma/mongokafkatutorial:latest bash

==============================================================================================================
'''
