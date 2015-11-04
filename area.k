# 'abstract' base class for hand areas
# The input (movement) and output (sending midi) are
# sperated into two tasks. (Avoid blocking of output.)
# Child classes should define their own handling methodes
# for input and output, see 
# - $.update (input handle) and
# - $.play (output handle).
class area {
	method init(dimX,dimY,dimZ) {
		if( nargs() == 1 && typeof(dimX) == "array" ){
			$.dim = dimX
		}else{
			if( nargs() < 3 ) dimZ = 1
			if( nargs() < 2 ) dimY = 1
			if( nargs() < 1 ) dimX = 1
			$.dim = [0=dimX,1=dimY,2=dimZ]
		}

		verbose("create area")
		$.settings = []

		# Called by TUIO reciver class
		$.update = $.update_handler

		# Called in Play/Output loop
		$.play = $.play_handler

		# Store id of play task.
		# Required for delete()
		# Set id like
		#	$.loopid = task $.playloop()
		$.loopid = -1
	}

	method update_handler(areaid, handid, xyz) {
		ix = floor( $.dim[0]*xyz[0])
		iy = floor( $.dim[1]*xyz[1])
		iz = floor( $.dim[2]*xyz[2])
		verbose("update (area class)", handid, ix, iy, iz)
	}

	method play_handler(){
		verbose("play (area class)")
		sleeptill(Now+10b)
	}

	method playloop(){
		while(1){
			$$.play()
		}
	}

	method get_settings() {
		return($$.settings)
	}

	# Mapping of [0,1]³ onto [0,dimX]x[0,dimY]x[0,dimZ]
	# for indizies = [0=0,1=1,2=2]. Other indizies could be used to swap dimensions or
	# to derive just one compontent.
	method get_ixyz(xyz, indizies ) {
		i = []
		for( k in indizies ){
			i[k] = floor( $.dim[indizies[k]] * xyz[indizies[k]] ) 
		}
		return(i)
	}

	# Print information about class
	# and keys of settings array.
	method help( parent ) {
		if( nargs() > 0 && typeof(parent) == "object" ){
			print("Available settings:")
			for( s in parent.get_settings() ){
				print("  ", s)
			}
		}else{
			print("Abstract class area.")
			print("Call help method of derived classes\n for more detailed information.\n")
		}
		print(" Number of slices: \n", $.dim[0], "\thorizontal,\n", $.dim[1], "\tvertical,\n", $.dim[2], "\tdepth")
	}

	method delete() {
		#print("delete area")
		if( $$.loopid != -1 ){
			verbose($$.loopid, $.loopid)
			kill($$.loopid)
		}
	}

	# Return name of (top level) class.
	method classof {
		return($$.class)
	}
}

