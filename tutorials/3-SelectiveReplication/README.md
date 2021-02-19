# Tutorial 3 - Selective Replication

Starting with version 1.4 of the connector, you can specify the MongoDB Change Stream Handler on the sink to read and replay MongoDB events sourced from MongoDB. In this tutorial we will launch the Kafka and MongoDB cluster baseline docker configuration, configure a source and sink connector against the "source" and "destination" collections respectively. Next we will connect to the local MongoDB cluster and issue basic insert, update and delete operations on the "source" collection and view these changes in the "destination" cluster.  We will also look at the Change Stream Message as it exists in the Kafka Topic.

## Step 3.1: Stand up the Tutorial Docker environemnt

To start the baseline tutorial environemnt execute the shell script `run.sh`.
```sh run.sh```

> Note: If you are using a Windows OS, execute the `run.ps1` script a Powershell environment.

## Step 3.2: Launch the TutorialShells

All the tools needed for these tutorial are loaded a docker image.  To use this image, open a command or terminal window and create a connection to our TutorialShell container as follows:

```docker run --rm --name shell1 --network kafka-edu_localnet -it tutorialshell:0.1 bash```

All commands listed in the following Tasks can be executed within the TutorialShell. 

This tutorial will use two shells, Shell1 and Shell2, open a second command shell window and launch:
```docker run --rm --name shell2 --network kafka-edu_localnet -it tutorialshell:0.1 bash```

## Step 3.3: Set up KafkaCat to watch a Kafka Topic 

Launch the following command in on **Shell 1**:

```kafkacat -b localhost:9092 -C -t Tutorial3.Source```

This comand will run KafkaCat as a consumer listening to message on the 'Tutorial3.Source' topic.  Next, let's use Shell2 to configure the source connector.

## Step 3.4: Configure the Source Connector
On **Shell2** execute the following:

```sh
curl -X POST -H "Content-Type: application/json" --data '
{"name":  "mongo-source-tutorial3-eventroundtrip",
"config": {
"connector.class":"com.mongodb.kafka.connect.MongoSourceConnector",
"connection.uri":"mongodb://mongo1:27017,mongo2:27017,mongo3:27017",
"database":"Tutorial3","collection":"Source"}}'```
http://localhost:8083/connectors -w "\n" | jq .
```

The Kafka Connect service is listening on port 8083.  This command will tell Kafka Connect to create a new connector instance of the MongoDB Connector called "mongo-source-tutorial3-eventroundtrip".  It should be configured as a source and listen to change stream events from the Source collection in the Tutorial3 database.

# Step 3.5: Configure the Sink connector
On **Shell2** execute the following:

```sh
curl -X POST -H "Content-Type: application/json" --data '
{"name": "mongo-sink-tutorial3-eventroundtrip", "config": {
"connector.class":"com.mongodb.kafka.connect.MongoSinkConnector",
 "tasks.max":"1",
 "topics":"Tutorial3.Source",
"change.data.capture.handler":"com.mongodb.kafka.connect.sink.cdc.mongodb.ChangeStreamHandler",
  "connection.uri":"mongodb://mongo1:27017,mongo2:27017,mongo3:27017",
  "database":"Tutorial3",
"collection":"Destination"}}' http://localhost:8083/connectors -w "\n" | jq .
```
The Kafka Connect service is listening on port 8083.  This command will tell Kafka Connect to create a new connector instance of the MongoDB Connector called "mongo-sink-tutorial3-eventroundtrip".  It will be configured as a sink and use the ChangeSteamHandler to interpret the messages in the Kafka Topic "Tutorial3.Source" as Change Stream Events.  The sink connector will write these events to the Destination collection in the Tutorial3 database.

## Step 3.6: Confirm the status of the connector
On **Shell2** execute the following:
Run the `status.h` script (e.g. `sh status.h`) and view the output.  Make sure the connectors are in an 'RUNNING' state.

An exmaple output of the status script is as follows:

```
Kafka topics:

[
  "docker-connect-status",
  "docker-connect-configs",
  "Tutorial3.Source",
  "docker-connect-offsets"
]

The status of the connectors:

sink    |  mongo-sink-tutorial3-eventroundtrip    |  RUNNING  |  RUNNING  |  com.mongodb.kafka.connect.MongoSinkConnector
source  |  mongo-source-tutorial3-eventroundtrip  |  RUNNING  |  RUNNING  |  com.mongodb.kafka.connect.MongoSourceConnector

Currently configured connectors

[
  "mongo-sink-tutorial3-eventroundtrip",
  "mongo-source-tutorial3-eventroundtrip"
]


Version of MongoDB Connector for Apache Kafka installed:

{"class":"com.mongodb.kafka.connect.MongoSinkConnector","type":"sink","version":"1.4.0"}
{"class":"com.mongodb.kafka.connect.MongoSourceConnector","type":"source","version":"1.4.0"}


MongoDB:

MongoDB shell version v4.4.2
connecting to: mongodb://localhost:27017/test?compressors=disabled&gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("1ed2c66f-8b76-41f1-b66d-e798ea966526") }
MongoDB server version: 4.4.2
4.4.2
```

## Step 3.7: Launch the Mongo Shell and insert data

In this task we will use the Mongo Shell to insert data in the Source collection and read the data that arrived from Kafka in the Desintation collection.
On **Shell2** connect to the MongoSH via the following:

```mongosh mongodb://mongo1:27017,mongo2:27017,mongo3:27017/?replicaSet=rs0```

Next insert some data.

```
use Tutorial3
db.Source.insert({proclaim: "Hello World!"});
```

## Step 3.8: Examine the data in the Kafka Topic

Now that data is written to the Source collection, the Change Stream event for the insertion will be raised, captured by the Connector and written to the Kafka Topic.

On **Shell1** view the output from KafkaCat.

Here is an example message of what you should see:

```json
{"schema":{"type":"string","optional":false},
"payload":{"_id": {"_data": "8260...4"}, 
"operationType": "insert", 
"clusterTime": {"$timestamp": {"t": 1611348141, "i": 2}},
"fullDocument": {"_id": {"$oid": "600b38ad..."}, "proclaim": "Hello World!"},
"ns": {"db": "Tutorial3", "coll": "Source"},
"documentKey": {"_id": {"$oid": "600b38a...."}}}}
```
Notice that the operationType is "insert".

## Step 3.9: Examine the data in the Desintation collection
Once the message reaches the Kafka topic, the sink connector will pick up the message and perform the operationType on the destination collection.

On **Shell2** issue the following query:
```db.Destination.find({}).pretty()```
Notice the data you inserted made its way from the source collection to the destination.

  {
    _id: ObjectId("600b38ad6011ef6265c3acd1"),
    proclaim: 'Hello World!'
  }

## Step 3.10: Explore update and delete events (optional)
Now that you have seen the insert operation through the destination collection.  Feel free to experiment and issue an update command to the data in the Source collection and confirm the change in the destination collection.

To update the record you can use this statement in the Mongo Shell (note you will have a different ObjectId, you can copy that from your db.find results in Task 8)

```db.Source.updateOne({"_id":ObjectId("Your ObjectID in Task 8 goes here!")},{ $set: { "name":"Rob"}})``

To verify the update use the find statement:
```db.Destination.find({}).pretty()```

To see the delete behavior, since we only have the one document you can remove all the documents in the Source collection as follows: 
```db.Source.remove({})```

To verify the delete use the find statement:
```db.Destination.find({}).pretty()```

# Summary
In this tutorial you configured the MongoDB Connector as both a source and sink.  First as a source to read data from the Source collection and then as a sink.  In the sink you configured it to use the ChangeStreamEvent handler.  This handler interpets the message in the kafka topic as a Change Stream Event and replays it on the destination namespace.  

Note: This capability is not intended as a replacement for a full featured replication system as it can not guarantee transactional consistency between the two clusters.
