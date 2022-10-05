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

  

To start the baseline tutorial environment execute the shell script `run.sh`.

```sh run.sh```

  

> Note: If you are using a Windows OS, execute the `run.ps1` script a Powershell environment.
  

Once the environment is running, you can use locally installed tools like MongoSH if you have them installed or use the  MongoDB Kafka Tutorial image.  This image contains tools like MongoSH, KafkaCat and other utilities.
 

```docker run --rm --name shell1 --network kafka-edu_localnet -it mongokafkatutorial:latest bash```


## Shutting down the Tutorial environment

  

The Docker environment can be stopped using

`docker-compose down`

  

If you would like to drop the MongoDB databases as well as shutdown use

`docker-compose down -v`

  

To start the environment again just execute the `run.sh` shell script

`sh run.sh`

> Note: If you are using a Windows OS, execute the `run.ps1` script a Powershell environment.

  
  

## References

  

- [MongoDB Kafka Connector](https://docs.mongodb.com/kafka-connector/current/) online documentation.

- [Connectors to Kafka](https://docs.confluent.io/home/connect/overview.html)
- MongoDB Connector for Apache Kafka Tutorials (Link TBD)