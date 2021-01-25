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
echo "\n\nWaiting for the systems to be ready.."
function test_systems_available {
  COUNTER=0
  until $(curl --output /dev/null --silent --head --fail http://localhost:$1); do
      printf '.'
      sleep 2
      let COUNTER+=1
      if [[ $COUNTER -gt 30 ]]; then
        MSG="\nWARNING: Could not reach configured kafka system on http://localhost:$1 \nNote: This script requires curl.\n"

          if [[ "$OSTYPE" == "darwin"* ]]; then
            MSG+="\nIf using OSX please try reconfiguring Docker and increasing RAM and CPU. Then restart and try again.\n\n"
          fi

        echo -e $MSG
        exit 1
      fi
  done
}

test_systems_available 8082
test_systems_available 8083


#trap clean_up EXIT

echo -e "\nConfiguring the MongoDB ReplicaSet.\n"
docker-compose exec mongo1 /usr/bin/mongo --eval '''if (rs.status()["ok"] == 0) {
    rsconf = {
      _id : "rs0",
      members: [
        { _id : 0, host : "mongo1:27017", priority: 1.0 },
        { _id : 1, host : "mongo2:27017", priority: 0.5 },
        { _id : 2, host : "mongo3:27017", priority: 0.5 }
      ]
    };
    rs.initiate(rsconf);
}

rs.conf();'''

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

MongoDB 3-node cluster available on port 27017, 27018 27019
Kafka Broker on 9092
Kafka Zookeeper on 2181
Kafka Connect on 8083

Status of kafka connectors:
sh status.h

To stop these serivces:
docker-compose-down

To stop and remove the MongoDB database volumes:
docker-compose-down -v

==============================================================================================================
'''