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


# Setup a ALSA connection
# Adapt connect_alsa.sh on your environment if ness.
function enable_output(){
	LOWKEY=1
	outalsa = outport(1)
	mapport(0,outalsa)
	#system("./connect_alsa.sh ZynAddSubFX 0")
	system("${GRID_MUSIC_ROOT}/scripts/connect_alsa.sh ZynAddSubFX 0")
}


function kinect(func){
	enable_output()
	
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

