#!/bin/bash

START_TIME=`date +%s`
DEST_TIME=`expr $START_TIME + 10`
echo $START_TIME
echo $DEST_TIME
while [ $START_TIME -lt $DEST_TIME ]
do
  echo "[$START_TIME] waiting"
  START_TIME=`date +%s`
  sleep 1
done
