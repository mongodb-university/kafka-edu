# MongoDB Kafka connector customization

Example of writing a custom write strategy

./gradlew clean build

Then copy the `mongo-kafka-customization/build/libs/UpsertAsPartOfDocumentStrategy.jar`


## Customization

The build file (`build.gradle.kts`) has a number of variables that can be changed to help customize the build.

```kts
val projectArchiveBaseName = "UpsertAsPartOfDocumentStrategy" // Set the outputted jar base name
val mongoKafkaConnectVersion = "1.6.1" // Set the mongo kafka connect version
val mongoDriverVersion = "[4.3,4.3.99)"
val kafkaConnectApiVersion = "2.6.0"
```

# Creating your own write strategy / document id strategy

Simply add a new package & file to `./src/main/java` and it will be packaged up automatically.

You can also create a test in `./src/test/java` to test input / outputs before packaging and deploying.