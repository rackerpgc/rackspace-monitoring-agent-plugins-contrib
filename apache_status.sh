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

show_help() {
cat << EOF
USAGE: $0 [curl options]

Default: curl -s -m 30 http://localhost/server-status?auto

Curl options will be passed to the curl command and take the place of the default options above.

EOF
}

CURL_OPTS=$@

if [[ $1 == "-h" ]] || [[ $1 == "--help" ]] || [[ $1 == "?" ]] || [[ $1 == "-?" ]] || [[ $1 == "help" ]]
then
  show_help
  exit 0;
fi

if [[ -z ${CURL_OPTS} ]]
then
  CURL_TARGET="curl -s -m 30 http://localhost/server-status?auto"
else
  CURL_TARGET="curl ${CURL_OPTS}"
fi

STATUS=$(${CURL_TARGET})

if [[ -z $STATUS ]]
then
  echo "status ERROR"
  echo "metric STATUS string received no response from ${CURL_TARGET}"
  exit 1
elif [[ $STATUS != *Uptime* ]]
then
  echo "status ERROR"
  echo "metric STATUS string no receiving expected output from ${CURL_TARGET}"
  exit 1
else
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
fi

