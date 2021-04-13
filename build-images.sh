#!/bin/bash

echo "Building docker images used for MongoDB Kafka Connector tutorials.\n\n"

cd images/tutorialshell
docker build -t tutorialshell:0.1 .

cd ../stockgenmongo
docker build -t stockgenmongo:0.1 .