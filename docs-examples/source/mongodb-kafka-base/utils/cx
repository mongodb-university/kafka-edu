#!/bin/bash

if [ $# -eq 0 ]
  then
    echo -e "\n\nMongoDB Kafka Tutorial - Configure Kafka Connect helper script\n\nThis script will pass a JSON file to the Kafka Connect service.\n\nExample:\ncx sinmplesource.json\n\n"
    exit 1
fi

curl -X POST -H "Content-Type: application/json" -d @$1 http://connect:8083/connectors -w "\n" | jq .