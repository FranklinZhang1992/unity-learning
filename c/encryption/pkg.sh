#!/bin/bash

DST=$1

date_str=$(date "+%Y%m%d%H%M%S")
cd $DST
tar -czvf encryptor_demo_$date_str.tar.gz encryptor_tool_v1.o encryptor_tool_v2.o encryptor_tool_v3.o run.sh
