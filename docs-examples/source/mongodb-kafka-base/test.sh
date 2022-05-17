#!/bin/bash

arch=$(uname -m)
echo ${arch}

if [[ "${arch}" == "arm64" ]]; then
    export PLATFORM=linux/amd64 && MDBVERSION="4.4.16"
else
    export PLATFORM=linux/x86_64 && MDBVERSION="latest"
fi
echo "\nRunning on ${arch_name} setting platform to ${PLATFORM} and MongoDB Version to ${MDBVERSION}"
