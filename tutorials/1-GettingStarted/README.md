# Tutorial 1 - Getting Started with moving data between Kafka and MongoDB

This introductory tutorial provides a hands-on walk through of how you can move data from MongoDB into and out of Apache Kafka® without writing any code.

At the end of this tutorial you will be able to:

- Describe Kafka Connect 
- Describe how MongoDB Connector for Apache Kafka is installed in a Kafka environment
- Locate the online documentation for MongoDB source and sink configuration parameters
- Identify the minimum configuration parameters needed for source and sink
- Explain how the source connector gets data from MongoDB
- Explain how the sink connector writes data to MongoDB
- Test your knowledge by configuring a source and sink per specific requirements

## Part 1 - The world of Kafka Connect

[Kafka Connect](https://docs.confluent.io/platform/current/connect/) is an open source component of Apache Kafka that allows third party data sources such as MongoDB to easily integrate and exchange data within the Kafka ecosystem.  Kafka Connect can be deployed in stand alone mode or in a distributed configuration depending on your requirements.  The service exposes an API that third parties can write to.  Confluent, the company behind Apache Kafka, publishes a complete list of connectors on the [Confluent Hub](https://www.confluent.io/hub/).

The MongoDB Connector for Apache Kafka is an [open source connector](https://github.com/mongodb/mongo-kafka) written in Java and leverages the Kafka Connect API.  The connector can be used as both a source or a sink meaning it can consume data from MongoDB into a Kafka topic and it can write data out to a MongoB cluster, respectively.  Connectors including the one written by MongoDB are installed on the Kafka Connect in one of two ways.  First they can be [manually installed](https://docs.confluent.io/home/connect/install.html#install-connector-manually) by extracting the zip file contents to a folder then add this folder to the plugin.path configuration property of the [Kafka Conenctor’s worker configuration](https://docs.confluent.io/home/connect/userguide.html#installing-kconnect-plugins).  For example: `plugin.path=/usr/local/share/kafka/plugins`.  Alternatively they can be installed using the Confluent Hub tool created by Confluent.   In our tutorial we leveraged the confluent-hub tool to download and install the MongoDB connector as follows:
```confluent-hub install --no-prompt mongodb/kafka-connect-mongodb:latest```
This installation occurred in our tutorial setup as part of our Docker build of the kafka-connect image, specifically within the `Dockerfile-MongoConnect` file.

For a complete description of installation of connectors in Kafka Connect see the [Confluent documentation](https://docs.confluent.io/home/connect/userguide.html#installing-kconnect-plugins). 
Once connectors are installed they are configured by passing configuration properties to Kafka Connect. The Kafka Connect platform includes a number of [Source Configuration](https://docs.confluent.io/platform/6.0.1/installation/configuration/connect/source-connect-configs.html) properties that apply to all connectors.  These properties include things like name, the connector class to use and the maximum number of tasks.  Each connector builds upon this list of configuration properties and adds their own connector specific properties.  For example, the MongoDB source connector exposes the `copy.existing` parameter that tells the connector to copy existing data from source collections and convert them to Change Stream events before processing any current events.  A complete list of these configuration parameters for the Source and Sink can be found in the [MongoDB Connector online documentation](https://docs.mongodb.com/kafka-connector/current/).  
 In this tutorial we will use the `curl` command to configure the connector by passing a configuration via the REST API.  Later in this tutorial we will cover how to use MongoDB as a source and sink in more detail.  Before diving into the connector specifics, it is important to learn about one of the key technologies within MongoDB that enables the source connector, Change Streams.

## Part 2- Exploring MongoDB Change Streams

When used as a source connector, a connection is made to MongoDB and a Change Stream is created on the specified namespace that is defined in the connector configuration.  [Change streams](https://docs.mongodb.com/manual/changeStreams/) is a feature within MongoDB server and exists not just for the Kafka Connector but as a way for any client or application to subscribe to real-time data changes within the database for a single collection, a database or an entire deployment. 

To see how this works let’s open a command or terminal window and create a connection to our TutorialShell container as follows:

```docker run --rm --name shell1 --network kafka-edu_localnet -it tutorialshell:0.1 bash```

In another command or terminal window create a second instance of the TutorialShell:

```docker run --rm --name shell2 --network kafka-edu_localnet -it tutorialshell:0.1 bash```

We will now execute a Python app in shell1 that will open a change stream against the “Tutorial1” database and “orders” collection and print on the screen any events on this namespace.

### Step 2.1: Launch openchangestream Python application

On **Shell 1**, execute the following:

```python3 1-GettingStarted/openchangestream.py```

You should see this message:

Change Stream is opened on the Tutorial1.orders namespace.  Currently watching ...

### Step 2.2: Write data using mongosh

On **Shell 2**, connect to the local MongoDB cluster and insert data

```mongosh mongodb://mongo1:27017,mongo2:27017,mongo3:27017/?replicaSet=rs0```

Once connected:

```
use Tutorial1
db.orders.insertOne({“orderid”:1,”product”:”pizza”, “price”:50})
```

### Step 2.3: Observe event data

Notice on **Shell 1** that the change stream event has arrived and contains a lot of data.  A complete description of events is available in the [Change Stream MongoDB documentation](https://docs.mongodb.com/manual/reference/change-events/).  There are a few data points that are worth pointing out.  

**Resume Token: _id**

First just like every document in MongoDB has an _id so does the change stream event.  Here the _id here is used as a resume token.  This will be important later when we talk about connector failures.  For now, know that when you open a change stream you can optionally provide a resume token.  This will tell change streams to start providing event data starting from that token up until the current time.

**Type of operation: operationType**

In our example we inserted data and in our change stream event the operationType field is where this is identified.  We will also get other events such as update, delete and invalidate.

In this example we opened a stream and captured any change at all on the orders namespace.  There are times where you may not need to capture every single event such as in the case of an IoT application that could theoretically generate hundreds or thousands of events per second.  When you create the change stream, you can provide an aggregation pipeline to filter the events that are generated.

### Step 2.4: Launch pipelinechangestream.py

On **Shell1**, launch pipelinechangestream.py

If you have not done so already, stop the running Python application by hitting Control-C then run the pipelinechangestream.py application.

```python3 1-GettingStarted/pipelinechangestream.py```

You should see this message:

Change Stream is opened on the Tutorial1.sensors namespace.  Currently watching for values > 100…

### Step 2.5: Insert data

On **Shell 2**, insert some data using the mongosh tool:

```
use Tutorial1
db.sensors.insertOne({"type":"temp","value":50})
db.sensors.insertOne({"type":"temp","value":110})
db.sensors.insertOne({"type":"temp","value":90})
```

### Step 2.6: Observe event data

On **Shell 1**, observe the event data

Notice that there is only one event captured since we added the pipeline which filtered out only the events we wanted which was when the type was “temp” and the value is greater than 100.  

For reference the pipeline defined in the python application is as follows:

```[{"$match":{ "$and": [{"fullDocument.type":"temp"},{"fullDocument.value":{"$gte":100}}] }}]```

Now that you have a basic understanding of Change Streams, let’s see how it's used with the source connector.

## Part 3 - Moving data from MongoDB to Kafka - being a source

When used as a source, data from MongoDB gets written to a Kafka topic.  Under the covers the connector opens a Change Stream on MongoDB.  As events such as insert, update and delete are generated on MongoDB, the connector writes them to the Kafka topic via the Kafka Connect API.  It is important to note that the connector does not make any direct connection to the Kafka broker.  This allows Kafka Connect to scale the connectors and manage errors in a unified way.  

Let’s set up a simple example where we have a “orders” collection in MongoDB and want to write any new orders into a Kafka Topic so that downstream applications can process.

If you do not already have the shells open from the previous step, open a command or terminal window and create a connection to our TutorialShell container as follows:

```docker run --rm --name shell1 --network kafka-edu_localnet -it tutorialshell:0.1 bash```

In another command or terminal window create a second instance of our TutorialShell:

```docker run --rm --name shell2 --network kafka-edu_localnet -it tutorialshell:0.1 bash```

All commands in these steps are located in the steps.sh file for reference.

### Step 3.1: Configure source connector

On **Shell 1**, issue the following curl command:

```
curl -X POST -H "Content-Type: application/json" --data '
  {"name": "mongo-source-customers",
   "config": {
     "connector.class":"com.mongodb.kafka.connect.MongoSourceConnector",
     "connection.uri":"mongodb://mongo1,mongo2,mongo3",
     "database":"Tutorial1",
     "collection":"orders"
}}' http://connect:8083/connectors -w "\n" | jq .
```

Upon success, you will see a response from Kafka Connect as follows:

{
  "name": "mongo-source-customers",
  "config": {
    "connector.class": "com.mongodb.kafka.connect.MongoSourceConnector",
    "connection.uri": "mongodb://mongo1,mongo2,mongo3",
    "database": "Tutorial1",
    "collection": "orders",
    "name": "mongo-source-customers"
  },
  "tasks": [],
  "type": "source"
}


### Step 3.2: Insert data

On **Shell 1** make a connection to MongoDB:

```mongosh mongodb://mongo1:27017,mongo2:27017,mongo3:27017/?replicaSet=rs0```

Once connected:

```
use Tutorial1
db.orders.insertOne({“orderid”:1,”product”:”pizza”, “price”:14.99})
```

### Step 3.3: Monitor the Kafka Topic using KafkaCat

 [Kafkacat](https://github.com/edenhill/kafkacat) is an open source command line tool designed for interacting with Kafka.  As we progress through the tutorials more of the functionality will be utilized.  For now, let’s enumerate the topics available in Kafka:

On **Shell 2** launch KafkaCat and verify that our connector created the ‘Tutorial1.orders’ topic:

```kafkacat -b broker:29092 -L```

The output not only includes the topic names but the number of partitions per topic and other useful metadata.  Notice that the connector has already processed the data oim the collection and created the “Tutorial1.orders” topic.

Next, let’s read the topic:

```kafkacat -b broker:29092  -f '\nPartition: %p\tOffset: %o\n\nKey (%K bytes):\n\n%k\t\n\nValue (%S bytes):\n\n%s\n-------------------------\n\n' -t Tutorial1.orders```

Notice that we formatted the output of KafkaCat to include the Key and Value.  The -f option in Kafkcat allows us to print lots of useful information.  Here is a complete list of attributes that can be included in the format string:  

topic name (%t),
partition (%p)
offset (%o)
timestamp (%T)
message key (%k)
message value (%s)
message headers (%h)
key length (%K)
value length (%S)

Recall that each message in a Kafka topic has both a Key and Value.  This is important to know as some of the more advanced use cases of the connector may reference or manipulate the key and/or value of the kafka topic message.

Partition: 0	Offset: 1

Key (198 bytes):

{"schema":{"type":"string","optional":false},"payload":"{\"_id\": {\"_data\": \"826023F02D000000022B022C0100296E5A100480C51D5B635F45CBB1CE2AEFF448654746645F696400646023F02DA5AB93B45512B8770004\"}}"}	

Value (549 bytes):

{"schema":{"type":"string","optional":false},"payload":"{\"_id\": {\"_data\": \"826023F02D000000022B022C0100296E5A100480C51D5B635F45CBB1CE2AEFF448654746645F696400646023F02DA5AB93B45512B8770004\"}, \"operationType\": \"insert\", \"clusterTime\": {\"$timestamp\": {\"t\": 1612967981, \"i\": 2}}, \"fullDocument\": {\"_id\": {\"$oid\": \"6023f02da5ab93b45512b877\"}, \"orderid\": 1, \"product\": \"pizza\", \"price\": 14.99}, \"ns\": {\"db\": \"Tutorial1\", \"coll\": \"orders\"}, \"documentKey\": {\"_id\": {\"$oid\": \"6023f02da5ab93b45512b877\"}}}"}

Recall when we issued the curl statement we passed this source configuration:
```
{"name": "mongo-source-customers",
   "config": {
     "connector.class":"com.mongodb.kafka.connect.MongoSourceConnector",
     "connection.uri":"mongodb://mongo1,mongo2,mongo3",
     "database":"Tutorial1",
     "collection":"orders"
}}
```

> Note: This configuration provides the minimum information needed to configure the source connector.  In addition to these properties there are many options available for you to use to change the behavior of the source connector and to support various use cases.  In this tutorial we will cover just a few of these options, however, for a complete list check out the [MongoDB Kafka Connector Source](https://docs.mongodb.com/kafka-connector/current/kafka-source/) documentation.

Recall that our “value” part of the kafka message includes a “payload” field.  This field has as its value the change stream event that was generated from our MongoDB source. 

### Step 3.4: Filtering events using the pipeline configuration parameter

Recall from Part 2, you learned about applying a pipeline to a change stream and only capturing events that applied.  This same pipeline is exposed as a source configuration parameter.  

On **Shell 1**, configure the source connector with the pipeline:

```
curl -X POST -H "Content-Type: application/json" --data '
  {"name": "mongo-source-sensors",
   "config": {
     "connector.class":"com.mongodb.kafka.connect.MongoSourceConnector",
     "connection.uri":"mongodb://mongo1,mongo2,mongo3",
     "database":"Tutorial1",
     "Collection":"sensors",
     "pipeline":"[{\"$match\":{ \"$and\": [{\"fullDocument.type\":\"temp\"},{\"fullDocument.value\":{\"$gte\":100}}] }}]"
}}' http://connect:8083/connectors -w "\n" | jq .
```

### Step 3.5: Insert data 

On **Shell 2** make a connection to MongoDB using Mongsh:

```mongosh mongodb://mongo1:27017,mongo2:27017,mongo3:27017/?replicaSet=rs0```

Once connected, insert data into MongoDB:

```
use Tutorial1
db.sensors.insertOne({“type”:”temp,”value”:101})
```

### Step 3.6: Observe data using KafkaCat 

On **Shell 1** launch Kafkacat and observe the incoming message:
```kafkacat -b broker:29092  -f '\nPartition: %p\tOffset: %o\n\nKey (%K bytes):\n\n%k\t\n\nValue (%S bytes):\n\n%s\n-------------------------\n\n' -t Tutorial1.sensors```

Notice that if you insert data that does not conform to the pipeline it will not be written to the kafka topic.


### Step 3.5: Copying existing data

In cases where you have existing data that is in a collection, you can process this data first before enabling the change stream on that namespace.  The `copy.existing` parameter copies existing data from source collections and converts them to Change Stream events. Any changes to the data that occur during the copy process are applied once the copy is completed.  To see how this works, let’s first insert some data into a MongoDB collection:

On **Shell 2** make a connection to MongoDB using Mongsh:

```mongosh mongodb://mongo1:27017,mongo2:27017,mongo3:27017/?replicaSet=rs0```

Once connected:

```
use Tutorial1
for (var i = 1; i <= 25; i++) { db.weather.insertOne({"type":"temp","value":Math.round(i*Math.random()+50) }) }
```
Here we are putting 25 temperature readings into the sensors collection.  Next, let’s create a source connector that is set up to copy the existing data first.

On **Shell 1** create the source connector:

curl -X POST -H "Content-Type: application/json" --data '
  {"name": "mongo-source-sensors-copy",
   "config": {
     "connector.class":"com.mongodb.kafka.connect.MongoSourceConnector",
     "connection.uri":"mongodb://mongo1,mongo2,mongo3",
     "database":"Tutorial1",
     "Collection":"weather",
"copy.existing":"true"
}}' http://connect:8083/connectors -w "\n" | jq .

Next, let’s take a look at the Kafka Topic, “Tutorial1.weather”.

```kafkacat -b broker:29092 -t Tutorial1.weather```

Notice that the existing data was processed as Change Stream events in the Kafka topic.


## Part 4 - Moving data from Kafka to MongoDB - being a sink

When used as a sink, the connector receives events from Kafka Connect.  These event messages are processed by the MongoDB connector and written to the desired collection that was defined in the sink configuration. Note that the connector doesn’t make a direct connection to a Kafka broker, rather all event messages arrive through Kafka Connect.  This is important when it comes time to troubleshoot or check for error messages.  It also makes it easy to scale since Kafka Connect can control the number of workers and connections to the Kafka broker.

The minimal configuration for the sink is similar to the source, but this time your database and collection is the namespace to write data from a kafka topic. The other required parameter is the name of the kafka topic to source the messages.  

If you do not still have the two shells open from the previous section, open a command or terminal window and create a connection to our TutorialShell container as follows:

```docker run --rm --name shell1 --network kafka-edu_localnet -it tutorialshell:0.1 bash```

In another command or terminal window create a second instance of our TutorialShell:

```docker run --rm --name shell2 --network kafka-edu_localnet -it tutorialshell:0.1 bash```
 
### Step 4.1: Configure sink connector

On **Shell 1**, issue the following curl command:

```
curl -X POST -H "Content-Type: application/json" --data '
  {"name": "mongo-sink-earthquakes",
   "config": {
     "connector.class":"com.mongodb.kafka.connect.MongoSinkConnector",
     "connection.uri":"mongodb://mongo1,mongo2,mongo3",
     "database":"Tutorial1",
     "collection":"earthquakes",
  "topics":"Tutorial1.earthquakes",
   "value.converter": "org.apache.kafka.connect.json.JsonConverter",
"value.converter.schemas.enable": "false",
   "key.converter": "org.apache.kafka.connect.json.JsonConverter",
"key.converter.schemas.enable": "false"

}}' http://connect:8083/connectors -w "\n" | jq .
```
Next, let’s use KafkaCat to load a JSON file into the Tutorial1.earthquakes topic.

```
kafkacat -b broker:29092 -t Tutorial1.earthquakes -l -P -T earthquakes.json

```


### Step 4.2: View the results in MongoDB

On **Shell 2**, connect to Mongo Shell and query for the data.  If you do not already have a connection:

```mongosh mongodb://mongo1:27017,mongo2:27017,mongo3:27017/?replicaSet=rs0```

Once connected, insert data into MongoDB:

```
use Tutorial1
db.earthquakes.find()
```
You can see that the data was written to the earthquakes collection per the sink configuration.

## Challenge: Protect the factory floor!

So far we have covered the basics of getting data into and out of Kafka using the MongoDB Connector for Apache Kafka.  Now it is your turn to apply what you’ve learned by solving this challenge:

Consider the following scenario:

You are an engineer at a company that manufactures chemical compounds that require the temperature in the factory to be below 32 degrees.  The company has many safety applications that need to be notified when a temperature violation occurs.

The IoT Temperature sensors on the factory floor are storing their data in MongoDB.  Using the following parameters build both a source and sink configuration that would address these required capabilities.

**MongoDB Source**
Database: IoTData
Collection: sensors
**Sample document:**
```json
{
 _id: ObjectId(xxx)
  sensorid:1,
  temperature: 20
}
```

**KafkaTopic:**
Alerts.IoTData.sensors

**MongoDB Destination**
Database: FactoryFloor
Collection: OperationalEvents


### Question 1
What is the source configuration to write data to the Alerts.IoTData.sensors topic only when the “temperature” field exceeds the value 32?

### Question 2
What is the sink configuration to write data from the Kafka topic, “Alerts.IoTData.sensors” to the FactoryFloor database?

### Question 3
Application owners that are consuming the data from the Kafka topic complain that the message contents are not just the document rather its the document and a lot of other stuff.  This stuff you notice is the Change Stream event.  What source parameter could you add to only publish the full document and not the change stream?  What will the source configuration look like with this new property?

Finished?  Check out the solution to the challenge  (links to a separate .md file)

If you are having trouble, read up on these configuration parameters
[Custom Pipeline](https://docs.mongodb.com/kafka-connector/current/kafka-source/#custom-pipeline-example)
[Topic naming example](https://docs.mongodb.com/kafka-connector/current/kafka-source/#topic-naming-example)

**Comments or feedback on this tutorial?  Please post them on the [Connectors community forum](https://developer.mongodb.com/community/forums/c/connectors-integrations/48). **
