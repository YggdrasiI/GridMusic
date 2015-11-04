# Use this file and the following script to call GridMusic
# without GUI.
# Copy keyrc.k from ./lib/ into ./
#
# #!/bin/sh
# export LD_LIBRARY_PATH=/usr/X11R6/lib
# export DISPLAY=""
# export KEYROOT=/opt/kinect/keykit/key77b
#
# Func="settingPiano"
# test -z "$1" || Func="$1"
# $KEYROOT/bin/key_alsa contrib/GridMusic/start.k -c "kinect(\"$Func\")"

GRIDMUSIC_PATH = "../contrib/GridMusic"
#include contrib/GridMusic/kinect.k
#include contrib/GridMusic/mysettings.k
##include basic1.k

function kinect(func){
	LOWKEY=1
	#enable outport 1 on startup
	outalsa = outport(1)
	mapport(0,outalsa)

	# Mapping from setting key (string) to start function.
	fhandles=["settingTest"=(settingTest)
	,"settingPiano"=(settingPiano)
	,"piano"=(settingPiano)
	,"settingGst"=(settingGst)
	#	,"kinectSet1"=(kinectSet1)
	#	,"kinectSet2"=(kinectSet2)
	,"halloween"=(settingHalloween)
	,"h2"=(settingH2)
	]
	printf("Start %s\n", func)
	fhandles[func]()
}

