# Windows Powershell script to launch the MongoDB Conector for Apache Kafka Tutorials


function Wait-KeyPress
{
    param
    (
        [ConsoleKey]
        $Key = [ConsoleKey]::Escape
    )
    do
    {
        $keyInfo = [Console]::ReadKey($false)
    } until ($keyInfo.Key -eq $key)
}

function CheckMongoDB
{
  $ipaddress = "127.0.0.1"
  $port = 27017

try {

$connection = New-Object System.Net.Sockets.TcpClient($ipaddress, $port)

if ($connection.Connected) {

     Write-Host "MongoDB is running on port 27017, please terminate the local mongod on this port." -ForegroundColor Yellow
     Exit 1
  }
}

catch {
    Write-Host "No MongoDB running..."
}

}

Write-Host "Checking to see if MongoDB is running..."

CheckMongoDB

Write-Host  "Starting docker ."

docker-compose up -d --build

Write-Host  "Configuring the MongoDB ReplicaSet."

docker-compose exec mongo1 /usr/bin/mongo --eval "if (rs.status()['ok'] == 0) { rsconf = { _id : 'rs0', members: [ { _id : 0, host : 'mongo1:27017', priority: 1.0 }, { _id : 1, host : 'mongo2:27017', priority: 0.5 }, { _id : 2, host : 'mongo3:27017', priority: 0.5 } ] }; rs.initiate(rsconf); } rs.conf();"

Write-Host  "

==============================================================================================================

The following services are running:

MongoDB 3-node cluster available on port 27017, 27018 27019
Kafka Broker on 9092
Kafka Zookeeper on 2181
Kafka Connect on 8083

Status of kafka connectors:
sh status.h

To stop these serivces:
docker-compose-down

To stop and remove the MongoDB database volumes:
docker-compose-down -v

An image has been created that includes all the client tools needed for the tutorials such as MongoShell, KafkaCat, etc:
docker run --rm --name shell1 --network kafka-edu_localnet -it tutorialshell:0.1 bash


==============================================================================================================
"

# docker-compose down  -v

# note: we use a -v to remove the volumes, else you'll end up with old data