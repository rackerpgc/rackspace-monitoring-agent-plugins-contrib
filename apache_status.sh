#!/bin/bash

## Rackspace Cloud Monitoring Plug-In
## Apache server-status details
#
# (C)2013 Philip Gates-Crandall <philip.gates-crandal@rackspace.com>
# All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Usage:
# Place plug-in in /usr/lib/rackspace-monitoring-agent/plugins
#

USER=$1
PASSWORD=$2

if [[ -z $USER && -z $PASSWORD ]]
then
  STATUS=$(curl -s http://localhost/server-status?auto)
else
  STATUS=$(curl -u ${1}:${2} -s http://localhost/server-status?auto)
fi
IFS=$'\n'

echo 'status OK'
for item in $STATUS
do
  if [[ $item == *Scoreboard* ]]
    then
      echo $item | awk -F':' '{gsub(" ", "", $1);print "metric "$1" string "$2}'
  else
      echo $item | awk -F':' '{gsub(" ", "", $1);print "metric "$1" int "$2}'
  fi
done

