#GRIDMUSIC_PATH = "../contrib/GridMusic" # unused

#define elif else if

# Setup a ALSA connection
# Adapt connect_alsa.sh on your environment if ness.
function enable_output(){
	outalsa = outport(1)
	mapport(0,outalsa)
	#system("./connect_alsa.sh ZynAddSubFX 0")
	system("${GRID_MUSIC_ROOT}/scripts/connect_alsa.sh ZynAddSubFX 0")
}
