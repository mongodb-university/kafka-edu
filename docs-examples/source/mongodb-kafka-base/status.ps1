Write-Host  "Kafka topics:"

Invoke-RestMethod -Uri http://localhost:8082/topics | ConvertTo-Json

Write-Host  "The status of the connectors:"

Invoke-RestMethod -Uri  "http://localhost:8083/connectors?expand=info&expand=status" | ConvertTo-Json

Write-Host "Currently configured connectors"
Invoke-RestMethod -Uri http://localhost:8083/connectors | ConvertTo-Json

Write-Host "Version of MongoDB Connector for Apache Kafka installed:"
Invoke-RestMethod -Uri http://localhost:8083/connector-plugins | ConvertTo-Json 
#'.[] | select( .class == "com.mongodb.kafka.connect.MongoSourceConnector" or .class == "com.mongodb.kafka.connect.MongoSinkConnector" )'

Write-Host "MongoDB:"
docker-compose exec mongo1 /usr/bin/mongo localhost:27017 --eval "db.version()"
