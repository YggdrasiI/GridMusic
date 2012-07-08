# 'abstract' base class for hand areas
class area {
	method init(dimX,dimY,dimZ) {
		verbose("create area")
		$.dimX = dimX
		$.dimY = dimY
		$.dimZ = dimZ

		$.update = $.update_handler
		$.play = $.play_handler

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
		#$.play = $$.play
		$.play = $.play_handler2
		sleeptill(Now+10b)
	}

	method play_handler2(){
		verbose("play2 (area)")
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

