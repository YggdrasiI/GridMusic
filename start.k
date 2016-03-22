# Use this file and scripts/lowkey.sh to start
# GridMusic without GUI.
#
# Copy keyrc.k from ./lib/ into ./ (Edit: Not nesscessary?!)
#

#include contrib/GridMusic/base_functions.k
#include contrib/GridMusic/kinect.k

#function kinectX(funcname){
#	LOWKEY=1
#
#	# Invoke including of all ness files.
#	##include contrib/GridMusic/base_functions.k
#	##include contrib/GridMusic/kinect.k
#	enable_output()
#
#	handle = SETTINGS[string(funcname)]
#	if( typeof(handle) == "function" ){
#		printf("Start configuration %s\n", funcname)
#		handle()
#	}else{
#		printf("Error! Configuration %s not found.\nDoes SETTINGS variable contains your handler?\n\n", funcname)
#	}
#}

function start_kinect(funcname){
	LOWKEY=1
  enable_output()
  k = new kinect(funcname, 0)
  k.start()
}
