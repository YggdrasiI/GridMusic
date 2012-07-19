# Use this file and the following script to call GridMusic 
# without GUI.
#
# #!/bin/sh
# export LD_LIBRARY_PATH=/usr/X11R6/lib
# export DISPLAY=""
# export KEYROOT=/opt/softwareSources/keykit/key77b
# $KEYROOT/bin/key_alsa contrib/GridMusic/start.k -c "kinect()"

#include contrib/GridMusic/kinect.k
function kinect(){
	LOWKEY=1
	settingPiano()
}
