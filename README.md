# MongoDB Connector for Apache Kafka Tutorials

*NOTE: These tutorials are currently under development.  Check the [MongoDB.com blog site](https://www.mongodb.com/blogs) for a formal announcement when completed in CY21.*

The official MongoDB Connector for Apache® Kafka® is developed and supported by MongoDB engineers and verified by Confluent. The Connector is designed to be used with Kafka Connect and enables MongoDB to be a datasource for Apache Kafka from both a source and sink perspective.

![](https://webassets.mongodb.com/_com_assets/cms/mongodbkafka-hblts5yy33.png)

These tutorials are focused on teaching you the essential features and functionality of the connector enabling you to get up and running quickly.  

Each tutorial is located in a subdirectory on this repository.  All tutorials will leverage the Docker environment found in the root folder in this repository.  To work through any of the tutorials read the README file within each folder to get started.

# Prerequisites

The tutorials use the following applications.  Install them locally first before starting tutorials

- [jq](https://stedolan.github.io/jq/download/)
- [KafkaCat](https://github.com/edenhill/kafkacat)
- [Docker](https://docs.docker.com/get-docker/)
- [Mongosh](https://docs.mongodb.com/mongodb-shell/install/)

# Starting the Docker environemnt

To start the baseline tutorial environemnt execute the shell script `run.sh`.
```sh run.sh```

This shell script will stand up the following Docker environment:

- MongoDB replica set
- Apache Kafka Bootstrap
- Apache Kafka Broker
- Apache Kafka Connect

Once the environment is running, use the `status.h` script to confirm the setup and configuration of this tutorial environment.
`sh status.h`

## Tutorials

The following is a list of available tutorials:


| Tutorial      | Description | Link |
| :---        |    :----   | :----   |
| 1 - Getting Started      | Coming Soon       | |
| 2- Using Schemas   | Coming Soon        | |
| 3- Event Roundtrip   | Explore replicating data between MongoDB clusters through Kafka using the ChangeStreamEvent handler        | [Tutorial 3]() |

## Shutting down the Tutorial environment

The Docker environemnt can be stopped using
`docker-compose down`

If you would like to drop the MongoDB databases as well as shutdown use
`docker-compose down -v`

To start the environment again just execute the `run.sh` shell script
`sh run.sh`

## References

- [MongoDB Kafka Connector](https://docs.mongodb.com/kafka-connector/current/) online documentation.
- [Connectors to Kafka](https://docs.confluent.io/home/connect/overview.html)

