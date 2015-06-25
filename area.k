# 'abstract' base class for hand areas
# The input (movement) and output (sending midi) are
# sperated into two tasks. (Avoid blocking of output.)
# Child classes should define their own handling methodes
# for input and output, see 
# - $.update (input handle) and
# - $.play (output handle).
class area {
	method init(dimX,dimY,dimZ) {
		verbose("create area")
		$.dimX = dimX
		$.dimY = dimY
		$.dimZ = dimZ

		$.update = $.update_handler
		$.play = $.play_handler

		# Store id of play task.
		# Required for delete()
		#	$.loopid = task $.playloop()
		$.loopid = -1
	}

	method update_handler(areaid,handid,x,y,z){
		ix = floor($.dimX*x)
		iy = floor($.dimY*y)
		iz = floor($.dimZ*z)
		verbose("update (area)", handid, ix, iy, iz)
	}

	method play_handler(){
		verbose("play (area)")
		# Reassign Example
		$.play = $.play_handler
		sleeptill(Now+10b)
	}

	method playloop(){
		while(1){
			$$.play()
		}
	}

	method delete() {
		#print("delete area")
		if( $$.loopid != -1 ){
			verbose($$.loopid, $.loopid)
			kill($$.loopid)
		}
	}

}

