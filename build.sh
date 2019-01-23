#!/bin/bash
# Builds the gear/container
# The container can be exported using the export.sh script

GEAR=scitran/afq-pipeline
docker build --tag $GEAR:$1 .
