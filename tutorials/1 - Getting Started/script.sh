
#source

curl -X POST -H "Content-Type: application/json" --data '
  {"name": "mongo-source-stockdata",
   "config": {
     "tasks.max":"1",
     "connector.class":"com.mongodb.kafka.connect.MongoSourceConnector",
     "connection.uri":"mongodb://mongo1:27017,mongo2:27017,mongo3:27017",
     "database":"Stocks",
     "collection":"StockData"
}}' http://localhost:8083/connectors -w "\n" | jq .

# insert data into MongoDB

# see the data in the kafka topic
# kafkacat -b localhost:9092  -f 'Topic %t [%p] at offset %o: key %k: %s\n' -t Stocks.StockData

#notice the change stream event is included as the message, number of config parameters

#sink

curl -X POST -H "Content-Type: application/json" --data '
  {"name": "mongo-atlas-sink",
   "config": {
     "connector.class":"com.mongodb.kafka.connect.MongoSinkConnector",
     "tasks.max":"1",
     "topics":"stockdata.Stocks.StockData",
     "connection.uri":"'"$1"'",
     "database":"Stocks",
     "collection":"StockData",
     "key.converter":"org.apache.kafka.connect.storage.StringConverter",
     "value.converter":"io.confluent.connect.avro.AvroConverter",
     "value.converter.schema.registry.url":"http://schema-registry:8081"
}}' http://localhost:8083/connectors -w "\n" | jq .
