# Tutorial 2 - Converters and Transforms

Coming soon

```sh
curl -X POST -H "Content-Type: application/json" --data '
{"name": "mongo-source-file-part1", "config": {
"connector.class":"FileStreamSource",
 "tasks.max":"1",
 "topic":"Tutorial2.SourcePart1",
 "key.converter":"org.apache.kafka.connect.json.JsonConverter",
"value.converter":"org.apache.kafka.connect.json.JsonConverter",
"file":"Tutorial2-sensor-readings.txt"}}' http://connect:8083/connectors -w "\n" | jq .
```
# {"schema":{"type":"string","optional":false},"payload":"79.8"}

curl -X POST -H "Content-Type: application/json" --data '
{"name": "mongo-source-file-part2", "config": {
"connector.class":"FileStreamSource",
 "tasks.max":"1",
 "topic":"Tutorial2.SourcePart2",
 "key.converter":"org.apache.kafka.connect.json.JsonConverter",
"value.converter":"org.apache.kafka.connect.json.JsonConverter",
"transforms": "HoistField,Cast",
"transforms.HoistField.type": "org.apache.kafka.connect.transforms.HoistField$Value",
"transforms.HoistField.field": "temp",
"transforms.Cast.type": "org.apache.kafka.connect.transforms.Cast$Value",
"transforms.Cast.spec": "temp:float64",
"file":"Tutorial2-sensor-readings.txt"}}' http://connect:8083/connectors -w "\n" | jq .

# {"schema":{"type":"struct","fields":[{"type":"string","optional":false,"field":"temp"}],"optional":false},"payload":{"temp":"79.8"}}


