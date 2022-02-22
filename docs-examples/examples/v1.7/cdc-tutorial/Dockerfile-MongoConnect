FROM confluentinc/cp-kafka-connect:latest

RUN confluent-hub install --no-prompt mongodb/kafka-connect-mongodb:1.7.0

ENV CONNECT_PLUGIN_PATH="/usr/share/java,/usr/share/confluent-hub-components"
