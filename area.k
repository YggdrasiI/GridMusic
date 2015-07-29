# 'abstract' base class for hand areas
# The input (movement) and output (sending midi) are
# sperated into two tasks. (Avoid blocking of output.)
# Child classes should define their own handling methodes
# for input and output, see 
# - $.update (input handle) and
# - $.play (output handle).
class area {
	method init(dimX,dimY,dimZ) {
		if( nargs() < 3 ) dimZ = 1
		if( nargs() < 2 ) dimY = 1
		if( nargs() < 1 ) dimX = 1
		verbose("create area")
		$.dimX = dimX
		$.dimY = dimY
		$.dimZ = dimZ
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
		ix = floor( $.dimX*xyz[0])
		iy = floor( $.dimY*xyz[1])
		iz = floor( $.dimZ*xyz[2])
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
		return( $$.settings )
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
		print(" Number of slices: \n", $.dimX, "\thorizontal,\n", $.dimY, "\tvertical,\n", $.dimZ, "\tdepth")
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

