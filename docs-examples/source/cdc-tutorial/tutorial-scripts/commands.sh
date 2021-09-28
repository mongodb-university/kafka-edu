curl -X POST -H "Content-Type: application/json" --data '
{ "name":  "mongo-source-tutorial3-eventroundtrip",
  "config": {
    "connector.class":"com.mongodb.kafka.connect.MongoSourceConnector",
    "connection.uri":"mongodb://mongo1:27017,mongo2:27017,mongo3:27017",
    "database":"Tutorial3","collection":"Source"}
}' http://connect:8083/connectors -w "\n" | jq .

curl -X POST -H "Content-Type: application/json" --data '
{ "name": "mongo-sink-tutorial3-eventroundtrip", 
  "config": {
  "connector.class":"com.mongodb.kafka.connect.MongoSinkConnector",
  "tasks.max":"1",
  "topics":"Tutorial3.Source",
  "change.data.capture.handler":"com.mongodb.kafka.connect.sink.cdc.mongodb.ChangeStreamHandler",
  "connection.uri":"mongodb://mongo1:27017,mongo2:27017,mongo3:27017",
  "database":"Tutorial3",
  "collection":"Destination"}
}' http://connect:8083/connectors -w "\n" | jq .
