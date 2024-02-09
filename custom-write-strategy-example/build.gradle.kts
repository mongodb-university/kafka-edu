/*
 * Copyright 2021-present Ross Lawley
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

val projectArchiveBaseName = "UpsertAsPartOfDocumentStrategy" // Set the outputted JAR base name
val mongoKafkaConnectVersion = "<kafka version>" // Set the Kafka connector version to test
val mongoDriverVersion = "4.11.0"
val kafkaConnectApiVersion = "2.6.0"

buildscript {
    repositories {
        mavenCentral()
    }
}

plugins {
    `java-library`
}


java {
    sourceCompatibility = JavaVersion.VERSION_1_8
    targetCompatibility = JavaVersion.VERSION_1_8
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.mongodb.kafka:mongo-kafka-connect:${mongoKafkaConnectVersion}")
    implementation("org.mongodb:mongodb-driver-sync:${mongoDriverVersion}")
    implementation("org.apache.kafka:connect-api:${kafkaConnectApiVersion}")

    testImplementation(platform("org.junit:junit-bom:5.7.2"))
    testImplementation("org.junit.jupiter:junit-jupiter")
}

sourceSets {
    main {
        java.srcDir("src/main")
    }
}

tasks.test {
    useJUnitPlatform()
    testLogging {
        events("passed", "skipped", "failed")
    }
}

tasks.withType<JavaCompile> {
    options.encoding = "UTF-8"
}

tasks.jar {
    archiveBaseName.set(projectArchiveBaseName)
}
