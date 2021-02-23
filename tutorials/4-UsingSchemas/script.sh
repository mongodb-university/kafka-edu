
#source

curl -X POST -H "Content-Type: application/json" --data '
  {"name": "mongo-source-stockdata",
   "config": {
     "tasks.max":"1",
     "connector.class":"com.mongodb.kafka.connect.MongoSourceConnector",
     "output.json.formatter":"com.mongodb.kafka.connect.source.json.formatter.SimplifiedJson",
     "output.format.value":"schema",
     "output.schema.value":"{\"name\":\"MongoExchangeSchema\",\"type\":\"record\",\"namespace\":\"com.mongoexchange.avro\",\"fields\":[ {\"name\": \"_id\",\"type\": \"string\"},{\"name\": \"company_symbol\",\"type\": \"string\"},{\"name\": \"company_name\",\"type\": \"string\"},{ \"name\": \"price\",\"type\": \"float\"},{\"name\": \"tx_time\",\"type\": \"string\"}]}",
     "output.format.key":"json",
     "key.converter":"org.apache.kafka.connect.storage.StringConverter",
     "value.converter":"io.confluent.connect.avro.AvroConverter",
     "value.converter.schema.registry.url":"http://schema-registry:8081",
     "transforms": "InsertField",
     "transforms.InsertField.type": "org.apache.kafka.connect.transforms.InsertField$Value",
     "transforms.InsertField.static.field": "Exchange",
     "transforms.InsertField.static.value": "MongoDB",
     "publish.full.document.only": true,
     "connection.uri":"mongodb://mongo1:27017,mongo2:27017,mongo3:27017",
     "topic.prefix":"stockdata",
     "database":"Stocks",
     "collection":"StockData"
}}' http://localhost:8083/connectors -w "\n" | jq .

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

echo "\nAdding MongoDB Kafka Sink Connector for the MySQL topic mysqlstock.Stocks.StockData (key, value)=(Avro,Avro) into the 'stocks.stockdata' collection in Atlas"
curl -X POST -H "Content-Type: application/json" --data '
  {"name": "mysql-atlas-sink",
   "config": {
     "connector.class":"com.mongodb.kafka.connect.MongoSinkConnector",
     "tasks.max":"1",
     "topics":"mysqlstock.Stocks.StockData",
     "connection.uri":"'"$1"'",
     "database":"Stocks",
     "collection":"StockData",
     "transforms": "ExtractField,InsertField",
     "transforms.ExtractField.type":"org.apache.kafka.connect.transforms.ExtractField$Value",
     "transforms.ExtractField.field":"after",
     "transforms.InsertField.type": "org.apache.kafka.connect.transforms.InsertField$Value",
     "transforms.InsertField.static.field": "Exchange",
     "transforms.InsertField.static.value": "MySQL",
     "key.converter":"io.confluent.connect.avro.AvroConverter",
     "key.converter.schema.registry.url":"http://schema-registry:8081",
     "value.converter":"io.confluent.connect.avro.AvroConverter",
     "value.converter.schema.registry.url":"http://schema-registry:8081"
}}' http://localhost:8083/connectors -w "\n" | jq .
