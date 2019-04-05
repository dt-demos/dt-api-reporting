#!/bin/bash

# if you want to run in the background, run this command
#   ./loopAddDeviceData.sh &>/dev/null &
#
# to kill it first find it then kill <pid>
#   ps -ef | grep loop 
# 
# to watch log as it runs, tail the log
#   tail -f loopAddDeviceData.log

# this loops forever every X seconds
while :
do
  ./addDeviceData.sh && echo "Called addDeviceData.sh data @ "`date` >> addDeviceData.log
  sleep 60
done
