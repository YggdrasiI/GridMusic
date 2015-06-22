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
#include contrib/GridMusic/mysettings.k
#include basic1.k

function kinect(func){
	LOWKEY=1
	#enable outport 1 on startup
	outalsa = outport(1)
	mapport(0,outalsa) 
	fhandles=["settingTest"=(settingTest)
	,"settingPiano"=(settingPiano)
	,"settingGst"=(settingGst)
	#	,"kinectSet1"=(kinectSet1)
	#	,"kinectSet2"=(kinectSet2)
	,"halloween"=(settingHalloween)
	,"h2"=(settingH2)
	]
	printf("Start %s\n", func)
	fhandles[func]()
}

