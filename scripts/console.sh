#!/bin/bash
#
# Start server backend for python console
####################################

# Input handling
Func="pyconsole(3330)"
test -z "$1" || Func="pyconsole($1)" 

# Normalize path. GRID_MUSIC_ROOT will be used to find GridMusic/tests in Keykit
THIS_DIR=$(pwd)
export GRID_MUSIC_ROOT="${THIS_DIR%/scripts}"

# Setup variables
source ${GRID_MUSIC_ROOT}/scripts/environment.sh
export DISPLAY=""

# Kill running instance of keykit
killall $KEYKIT

# Script now called by Keykit itself, see GridMusic/start.k
#${GRID_MUSIC_ROOT}/scripts/connect_alsa.sh ZynAddSubFX 2 &

# Start
cd $KEYROOT
$KEYROOT/bin/$KEYKIT contrib/GridMusic/pyconsole.k -c "$Func" 
