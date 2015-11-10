#!/bin/bash
#
# Start Keykit
####################################

# Normalize path. GRID_MUSIC_ROOT will be used to find GridMusic/tests in Keykit
THIS_DIR=$(pwd)
export GRID_MUSIC_ROOT="${THIS_DIR%/scripts}"

# Setup variables
source ${GRID_MUSIC_ROOT}/scripts/environment.sh

# Kill running instance of keykit
killall $KEYKIT

# Connect with midi sequenzer after short delay
${GRID_MUSIC_ROOT}/scripts/connect_alsa.sh ZynAddSubFX 2 &

# Swtich into directory with keyrc.k
cd $KEYROOT
$KEYROOT/bin/$KEYKIT $* </dev/tty >/dev/tty 2>/dev/tty 
