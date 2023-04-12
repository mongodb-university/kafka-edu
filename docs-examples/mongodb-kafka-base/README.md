# MongoDB Connector for Apache Kafka Tutorials

The official MongoDB Connector for Apache® Kafka® is developed and supported by MongoDB engineers and verified by Confluent. The Connector is designed to be used with Kafka Connect and enables MongoDB to be a datasource for Apache Kafka from both a source and sink perspective.

![](https://webassets.mongodb.com/_com_assets/cms/mongodbkafka-hblts5yy33.png)

These tutorials are focused on teaching you the essential features and functionality of the connector enabling you to get up and running quickly.

# Prerequisites

The MongoDB Kafka tutorial environment requires the following installed on your client:

- [Docker](https://docs.docker.com/get-docker/)
- [Git]()

The docker compose in this repository will create an environment that consists of the following:

- Apache Kafka
- Zookeeper
- Apache Kafka Connect
- MongoDB Connector for Apache Kafka (installed in Kafka Connect)
- MongoDB single node replica set

# Starting the Docker environment

To start the baseline tutorial environment execute the run the following command:

```
docker-compose -p mongo-kafka up -d --force-recreate
```

To start an interactive shell, run the following command:

```
docker exec -it mongo1 /bin/bash
```

## Shutting down the Tutorial environment

To stop and remove the Docker environment from your
machine, run the following command:

```
docker-compose -p mongo-kafka down --rmi 'all'
```

## References

- [MongoDB Kafka Connector](https://docs.mongodb.com/kafka-connector/current/) online documentation.

- [Connectors to Kafka](https://docs.confluent.io/home/connect/overview.html)
- MongoDB Connector for Apache Kafka Tutorials (Link TBD)
