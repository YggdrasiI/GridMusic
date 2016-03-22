#!/bin/bash
# Search for keykit and ZynAddSubFX and connect both.

# Target application
TARGET="\(ZynAddSubFX\|FLUID\)"
test -z "$1" || TARGET="$1"

# Optional wait on keykit startup
WAIT_TIME=2
test -z "$2" || WAIT_TIME="$2"
sleep "$WAIT_TIME"

# Get port numbers
PORTIN=$(aconnect -i | grep keykit | tail -n 2 | grep lient | sed -n -e 's/^.*[Cc]lient \([0-9]\+\):.*$/\1/p')

PORTOUT=$(aconnect -o | grep $TARGET | tail -n 2 | grep lient | sed -n -e 's/^.*[Cc]lient \([0-9]\+\):.*$/\1/p')

# Connect ports
echo "aconnect ${PORTIN}:0 ${PORTOUT}:0"
aconnect ${PORTIN}:0 ${PORTOUT}:0
