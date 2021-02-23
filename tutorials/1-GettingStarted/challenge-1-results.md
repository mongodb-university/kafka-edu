# Challenge 1 - Protect the factory floor!  Results

## Question 1
**What is the source configuration to write data to the Alerts.IoTData.sensors topic only when the “temperature” field exceeds the value 32?**

```
curl -X POST -H "Content-Type: application/json" --data '
  {"name": "mongo-source-challenge1",
   "config": {
     "connector.class":"com.mongodb.kafka.connect.MongoSourceConnector",
     "connection.uri":"mongodb://mongo1,mongo2,mongo3",
     "database":"IoTData",
     "Collection":"sensors",
     "topic.prefix":"Alerts",
     "pipeline":"[{\"$match\":{\"fullDocument.temperature\":{\"$gt\":32}}}]",
     "publish.full.document.only":"true"
}}' http://connect:8083/connectors -w "\n" | jq .
```

Cnnecting to your MongoDB instances and inserting sample data that includes both temperatures that are below and above 32.

```db.sensors.insertOne({sensorid:1, temperature:20})```
```db.sensors.insertOne({sensorid:1, temperature:40})```
```db.sensors.insertOne({sensorid:1, temperature:70})```

Confirm that you get only two Kafka events from the sample data above.

```kafkacat -b broker:29092 -C -t Alerts.IoTData.sensors```

## Question 2
**What is the sink configuration to write data from the Kafka topic, “Alerts.IoTData.sensors” to the FactoryFloor database?**

curl -X POST -H "Content-Type: application/json" --data '
  {"name": "mongo-sink-sensor-alerts",
   "config": {
     "connector.class":"com.mongodb.kafka.connect.MongoSinkConnector",
     "connection.uri":"mongodb://mongo1,mongo2,mongo3",
     "database":"FactoryFloor",
     "collection":"OperationalEvents",
  "topics":"Alerts.IoTData.sensors"
}}' http://connect:8083/connectors -w "\n" | jq .


## Question 3
**Application owners that are consuming the data from the Kafka topic complain that the message contents are not just the document rather its the document and a lot of other stuff.  This stuff you notice is the Change Stream event.  What source parameter could you add to only publish the full document and not the change stream?**

The `publish.full.document.only` flag will not wrap the document with the change stream event metadata to the topic.

```
curl -X POST -H "Content-Type: application/json" --data '
  {"name": "mongo-source-challenge1",
   "config": {
     "connector.class":"com.mongodb.kafka.connect.MongoSourceConnector",
     "connection.uri":"mongodb://mongo1,mongo2,mongo3",
     "database":"IoTData",
     "Collection":"sensors",
     "topic.prefix":"Alerts",
     "pipeline":"[{\"$match\":{\"fullDocument.temperature\":{\"$gt\":32}}}]",
     "publish.full.document.only":"true"
}}' http://connect:8083/connectors -w "\n" | jq .
```
