#!/bin/bash

arch=$(uname -m)

# Apple M1 laptops running MongoDB 5.x inside Docker is currently not supported so we check and install latest 4.4 build 
if [[ "${arch}" == "arm64" ]]; then
    export PLATFORM=linux/amd64 && export MDBVERSION="mongo:4.4.14" && export MDBSHELL="/usr/bin/mongo"
else
    export PLATFORM=linux/x86_64 && export MDBVERSION="mongo:latest" && export MDBSHELL="/usr/bin/mongosh"
fi
echo "\nRunning on ${arch} setting platform to ${PLATFORM} and MongoDB Version ${MDBVERSION}"

docker-compose down -v
