#!/bin/bash
#
#Start GridMusic without gui
####################################

# Input handling
Func="settingPiano"  # Default setting
test -z "$1" || Func="$1" 

# Normalize path. GRID_MUSIC_ROOT will be used to find GridMusic/tests in Keykit
THIS_DIR=$(pwd)
export GRID_MUSIC_ROOT="${THIS_DIR%/scripts}"

# Setup variables
source ${GRID_MUSIC_ROOT}/scripts/environment.sh
export DISPLAY=""

# Kill running instance of keykit
killall $KEYKIT

# Connect with midi sequenzer after short delay.
# Note that this only works after keykit enabled it's midi output port.
# It is commented out here because GridMusic already calls the script,
# see GridMusic/base_functions.k + GridMusic/start.k 
#${GRID_MUSIC_ROOT}/scripts/connect_alsa.sh 2 ZynAddSubFX &

# Swtich into directory with keyrc.k
cd $KEYROOT
$KEYROOT/bin/$KEYKIT contrib/GridMusic/start.k -c "start_kinect(\"$Func\")" 
