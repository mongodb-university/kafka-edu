#!/bin/bash

arch=$(uname -m)

if [[ "${arch}" == "arm64" ]]; then
    export PLATFORM=linux/amd64
else
    export PLATFORM=linux/x86_64
fi

export MDBVERSION="mongo:6.0.1"
export MDBSHELL="/usr/bin/mongosh"

echo "\nStopping..."
docker-compose down -v
