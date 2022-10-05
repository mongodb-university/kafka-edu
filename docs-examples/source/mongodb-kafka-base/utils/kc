#!/bin/bash

if [ $# -eq 0 ]
  then
    echo -e "\n\nMongoDB Kafka Tutorial - View Kafka Topic helper script\n\nThis script displays the contents of a kafka topic.\n\nExample:\nkc topicname\n\n"
    exit 1
fi
# This function is a quick way to view the contents of the kafka topic
# Useage:  sh kc.sh <name of topic>
kafkacat -b broker:29092  -f '\nPartition: %p\tOffset: %o\n\nKey (%K bytes):\n\n%k\t\n\nValue (%S bytes):\n\n%s\n-------------------------\n\n' -t $1