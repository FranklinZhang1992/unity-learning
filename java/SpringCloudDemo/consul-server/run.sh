#!/bin/bash

BIND_IP=$1

if [ -n "$BIND_IP" ]; then
    echo "Run consult with bind: $BIND_IP"
    ./consul agent -ui -data-dir=/tmp/consul -bind=$BIND_IP -dev
else
    echo "Run consult"
    ./consul agent -ui -data-dir=/tmp/consul -dev
fi
