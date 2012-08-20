# Use this file and the following script to call GridMusic 
# without GUI.
#
# #!/bin/sh
# export LD_LIBRARY_PATH=/usr/X11R6/lib
# export DISPLAY=""
# export KEYROOT=/opt/kinect/keykit/key77b
#
# Func="settingPiano"
# test -z "$1" || Func="$1" 
# $KEYROOT/bin/key_alsa contrib/GridMusic/start.k -c "kinect(\"$Func\")" 

#include contrib/GridMusic/kinect.k
#include basic1.k

function kinect(func){
  LOWKEY=1
  fhandles=["settingTest"=(settingTest),"settingPiano"=(settingPiano),"settingGst"=(settingGst)]
  printf("Start %s\n", func)
  fhandles[func]()
}

