# This function is a quick way to delete a connectors configuration
# Useage:  sh del.sh <name of connector>
curl -X DELETE localhost:8083/connectors/$1