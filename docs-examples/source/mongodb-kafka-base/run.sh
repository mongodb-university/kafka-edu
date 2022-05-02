#!/bin/bash

set -e
(
if lsof -Pi :27017 -sTCP:LISTEN -t >/dev/null ; then
    echo "Please terminate the local mongod on 27017"
    exit 1
fi
)

echo "Starting docker ."
docker-compose up -d --build

sleep 5

echo "\nConfiguring the MongoDB ReplicaSet...\n"
# 5.0 and above we can use mongosh
#docker-compose exec mongo1 /usr/bin/mongosh --eval '''rsconf = { _id : "rs0", members: [ { _id : 0, host : "mongo1:27017", priority: 1.0 }]};
#rs.initiate(rsconf);'''

docker-compose exec mongo1 /usr/bin/mongo --eval '''rsconf = { _id : "rs0", members: [ { _id : 0, host : "mongo1:27017", priority: 1.0 }]};
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

MongoDB 3-node cluster available on port 27017
Kafka Broker on 9092
Kafka Zookeeper on 2181
Kafka Connect on 8083

Status of kafka connectors:
sh status.h

To stop these serivces:
docker-compose-down

To stop and remove the MongoDB database volumes:
docker-compose-down -v

(Optional) A docker image is avaialble which includes MongoSH shell, KafkaCat, and various utilitiies:
docker run --rm --name shell1 --network kafka-edu_localnet -it robwma/mongokafkatutorial:latest bash

==============================================================================================================
'''