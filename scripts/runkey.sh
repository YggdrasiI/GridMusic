#!/bin/bash
#
# Start Keykit with given arguments.
####################################

# Input handling
ARGS="print(\"Usage: $0 {Keykit CMD} [; Keykit CMD] ...\")"
if [ -n "$1" ] ; then
ARGS="$*" 
fi

# Normalize path. GRID_MUSIC_ROOT will be used to find GridMusic/tests in Keykit
THIS_DIR=$(pwd)
export GRID_MUSIC_ROOT="${THIS_DIR%/scripts}"

# Setup variables
source ${GRID_MUSIC_ROOT}/scripts/environment.sh
export DISPLAY=""

# Kill running instance of keykit
killall $KEYKIT

# Script now called by Keykit itself, see GridMusic/start.k
#${GRID_MUSIC_ROOT}/scripts/connect_alsa.sh 2 ZynAddSubFX &

# Start
cd $KEYROOT
$KEYROOT/bin/$KEYKIT keyrc.k -c "$ARGS" 
