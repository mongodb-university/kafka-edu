# This function is a quick way to view the contents of the kafka topic
# Useage:  sh kc.sh <name of topic>
kafkacat -b broker:9092  -f '\nPartition: %p\tOffset: %o\n\nKey (%K bytes):\n\n%k\t\n\nValue (%S bytes):\n\n%s\n-------------------------\n\n' -t $1