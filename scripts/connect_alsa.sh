#!/bin/bash
# Search for keykit and ZynAddSubFX and connect both.

# Use local environment file if available. Use this file as template, but do not add the local file to git repository.
LOCAL_FILE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )""/connect_alsa.local.sh"
if [ -e "${LOCAL_FILE}" -a "$AVOID_INF_LOOP" != "1" ] ; then
  AVOID_INF_LOOP=1
  source "${LOCAL_FILE}"
  AVOID_INF_LOOP=0
else

  # Wait on keykit startup
  WAIT_TIME=0
  test -z "$1" || WAIT_TIME="$1"
  sleep "$WAIT_TIME"

  # Target application
  TARGET="ZynAddSubFX"
  test -z "$2" || TARGET="$2"

  # Get port numbers
  PORTIN=$(aconnect -i | grep keykit | tail -n 2 | grep lient | sed -n -e 's/^.*[Cc]lient \([0-9]\+\):.*$/\1/p')

  PORTOUT=$(aconnect -o | grep $TARGET | tail -n 2 | grep lient | sed -n -e 's/^.*[Cc]lient \([0-9]\+\):.*$/\1/p')

  # Connect ports
  echo "aconnect ${PORTIN}:0 ${PORTOUT}:0"
  aconnect ${PORTIN}:0 ${PORTOUT}:0
fi
