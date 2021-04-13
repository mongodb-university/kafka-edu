# Coming soon

Currently working on the following tutorial text.  Here is a work in progress ->


# Put some sample orders in the Orders collection


 db.Orders.createIndex( { "order-id": 1 }, { unique: true } )

 db.Orders.insert( { 'customer-id':123,'order-id':100, 'order':{'lineitem':1,'SKU':'FACE1','quantity':1}})

 db.Orders.insert( { 'customer-id':456,'order-id':101, 'order':{'lineitem':2,'SKU':'FACE2','quantity':1}})

# create a source that reads from the OrderCancel collection

curl -X POST -H "Content-Type: application/json" --data '
  {"name": "mongo-source-orders",
   "config": {
     "connector.class":"com.mongodb.kafka.connect.MongoSourceConnector",
     "connection.uri":"mongodb://mdb1",
     "database":"FaceMaskWeb",
     "Collection":"OrderCancel",
     "publish.full.document.only":true,

     "value.converter":"org.apache.kafka.connect.json.JsonConverter",
     "value.converter.schemas.enable":false

}}' http://connect:8083/connectors -w "\n" | jq .


# create a sink that listens to the canceled topic
curl -X POST -H "Content-Type: application/json" --data '
{"name": "mongo-canceled-orders",
 "config": {
 "connector.class": "com.mongodb.kafka.connect.MongoSinkConnector",
    "topics":"FaceMaskWeb.OrderCancel",
    "connection.uri":"mongodb://mdb1",
    "database":"FaceMaskWeb",
    "collection":"Orders",
    "writemodel.strategy": "com.mongodb.kafka.connect.sink.writemodel.strategy.DeleteOneBusinessKeyStrategy",
    "document.id.strategy": "com.mongodb.kafka.connect.sink.processor.id.strategy.PartialValueStrategy",
    "document.id.strategy.partial.value.projection.type": "AllowList",
    "document.id.strategy.partial.value.projection.list": "order-id",
    "value.converter":"org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable":false,
    "document.id.strategy.overwrite.existing": true

}}' http://connect:8083/connectors -w "\n" | jq .

# delete order-id of 100
db.OrderCancel.insert({'order-id':100})






curl -X POST -H "Content-Type: application/json" --data '{"name": "mongo-cancel",  "config": {
   "connector.class": "com.mongodb.kafka.connect.MongoSinkConnector",
   "topics":"orders-cancel",
   "connection.uri":"mongodb://mongo1,mongo2,mongo3",
    "database":"FaceMaskWeb",
    "collection":"Orders",
    "writemodel.strategy": "com.mongodb.kafka.connect.sink.writemodel.strategy.DeleteOneBusinessKeyStrategy",
    "document.id.strategy": "com.mongodb.kafka.connect.sink.processor.id.strategy.PartialValueStrategy",
    "document.id.strategy.partial.value.projection.type": "allowlist",
    "document.id.strategy.partial.value.projection.list": "order-id",
    "value.converter":"org.apache.kafka.connect.json.JsonConverter",
    "tasks.max":"1"
}}' http://localhost:8083/connectors -w "\n" | jq .

That configuration is saying the topic contains data about records to be deleted and the sink data value is in this format:
{_id: x, ACCOUNTID: y, SALE_TS: z}
delete one document in the sink where the value of accountid in the topic message matches the value of accountid in the sink collection  ... deleteone when all three match
