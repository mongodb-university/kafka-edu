# MongoDB Kafka Connector Lite

This docker compose starts the following services:

- MongoDB single node replica set
- Kafka Connect
- Kafka Broker
- Kafka Zookeeper

## Usage

Perform the following actions to install MongoDB Kafka Connector source and sink connectors and send a document through Apache Kafka:

1. Start the docker environment by running the following command:

    docker-compose up -d

2. Enter the a shell in the docker environment with the following command:

    docker exec -it shell /bin/bash

3. Install connectors by running the following commands:

    curl -X POST -H "Content-Type: application/json" --data @source-connector.json http://connect:8083/connectors -w "\n"
    curl -X POST -H "Content-Type: application/json" --data @sink-connector-cdc.json http://connect:8083/connectors -w "\n"

4. Enter the MongoDB shell with the following command:

    mongosh mongodb://mongo1:27017/?replicaSet=rs0

5. Upload a document to the `source` collection in the `quickstart` database:

    use quickstart
    db.source.insertOne({"hello":"kafka"})

6. Wait 5-10 seconds and run the following command:

    db.sink.find()

   You should see a document resembling the following:

    {"_id":{"$oid":"<your id value>"},"hello": "kafka"}

To stop the process, exit the docker environment and run the following command:
    
    docker-compose down -v

## Documentation

For more information on the quick start pipeline, see the
[MongoDB Kafka Connector Documentation](https://docs.mongodb.com/kafka-connector/current/quickstart).
