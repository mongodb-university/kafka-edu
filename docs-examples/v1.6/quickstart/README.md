# MongoDB Kafka Connector Lite

This docker compose starts the following services:

- MongoDB single node replica set
- Kafka Connect
- Kafka Broker
- Kafka Zookeeper

## Usage

To start the environment, run the following command:

    docker-compose up -d

Once you have started the environment run the following command to enter the shell:

    docker exec -it shell /bin/bash

Once you are in the shell, you can install connectors by running the following commands:

    curl -X POST -H "Content-Type: application/json" --data @source-connector.json http://connect:8083/connectors -w "\n"
    curl -X POST -H "Content-Type: application/json" --data @sink-connector-cdc.json http://connect:8083/connectors -w "\n"

Once you install your connectors, enter the MongoDB shell with the following command:

    mongosh mongodb://mongo1:27017/?replicaSet=rs0

Run the following command to
upload a document to the `source` collection in the `quickstart` database:

    use quickstart
    db.source.insertOne({"hello":"kafka"})

After you insert a document, wait 5-10 seconds and run the following command:

    db.sink.find()

You should see a document resembling the following:

    {"_id":{"$oid":"60f4d4af6e615c38a77c59c6"},"welcome": "kafka"}

To stop the process you can use "Control-C" or `docker-compose down -v`

## Documentation

For more information on the quick start pipeline, see the
(MongoDB Kafka Connector Documentation)[https://docs.mongodb.com/kafka-connector/current/quickstart].
