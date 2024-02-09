# MongoDB Kafka connector customization

Example of writing a custom write strategy

./gradlew clean build

Then copy the `./build/libs/UpsertAsPartOfDocumentStrategy.jar`

## Customization

The build file (`build.gradle.kts`) has a number of variables that can
be changed to help customize the build. Set the value of the
`mongoKafkaConnectVersion` variable to the Kafka connector version you
want to test your write model strategy with.

```kts
val projectArchiveBaseName = "UpsertAsPartOfDocumentStrategy" // Set the outputted JAR base name
val mongoKafkaConnectVersion = "<kafka version>" // Set the Kafka connector version to test
val mongoDriverVersion = "4.11.0"
val kafkaConnectApiVersion = "2.6.0"
```

# Creating your own write strategy / document id strategy

Simply add a new package & file to `./src/main/java` and it will be packaged up automatically.

You can also create a test in `./src/test/java` to test input / outputs before packaging and deploying.
