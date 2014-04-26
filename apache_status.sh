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
USAGE: $0 [-h] [-u username:password] [-l location] [-p port] [-m timeout]

  -h print this help summary
  -u username:password - HTTP Authentication for curl (default none)
  -l location - the location of the Apache server-status module (default "/server-status?auto")
  -p port - the port that Apache is listening on (default 80)
  -m timeout - the length of time to try the request (default 30 seconds)
EOF
}

location="/server-status?auto"
port="80"
host="localhost"
timeout="30 seconds"

while getopts "u:l:p:m:h?" o; do
    case "${o}" in
        h)  show_help
            exit 0
            ;;
        u) user=${OPTARG}
           CURL_OPTS=${CURL_OPTS}" -u ${user}"
            ;;
        l) location=${OPTARG}
            ;;
        p) port=${OPTARG}
           CURL_HOST="${hostname}:${port}${location}"
            ;;
        m) timeout=${OPTARG}
           CURL_OPTS=${CURL_OPTS}" -m ${timeout}"
            ;;
        '?') show_help
             exit 0
            ;;
    esac
done

CURL_TARGET="http://${host}:${port}${location}"

STATUS=$(curl -s${CURL_OPTS} ${CURL_TARGET})

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

