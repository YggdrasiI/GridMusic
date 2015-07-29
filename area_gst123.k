#
# Use osc interface of gst123
#
class area_gst123{
	method init(mfilenames, volume_area) {

		#connect this object with volume panel (optional)
		if( nargs() > 1 ){
			volume_area.addListener( $, "setVol" )
		}

		$.volfactor = 1.0 # relative volume
		$.mfilenames = []
		i = 0
		for( n in mfilenames ){
			$.mfilenames[i] = mfilenames[n];
			i+=1
		}
		$.mfiles_size = sizeof($.mfilenames)	

		$.hand_is_in = 0
		$.playing = -1

		#first dim: file
		#second dim: volume
		#thrird dim: trigger 0/>1
		$.inherit( new area($.mfiles_size,2,10) )

		$.player = new gst123()

		$.update = $.update_handler
		$.play = $.play_handler

		#$.loopid = task $.playloop()
	}

	method update_handler(areaid, handid, xyz) {
		ix = rand( $.mfiles_size ) # random
		iy = floor( $.dimY*xyz[1])
		iz = floor( $.dimZ*xyz[2])
		lock($)
		if( iz < 1 ) $.hand_is_in = 0

		if(0 && $.playing > -1 ){
			$.volfactor = 2*y;
			$.setVol( GLOBALVOL )
			sleeptill(Now+1b)
		}

		if( iz < 4 || $.hand_is_in > 0 ){
			unlock($)
			return()
		}
		$.hand_is_in = 1
		if( $.playing > -1 ){
			$.playing = -1
			verbose("stop gst123")
			#$.player.pause()
			$.player.pause(1)
		}else{
			$.playing = ix
			verbose("start gst123 ", $.mfilenames[$.playing])
			#well, this mess the playlist
			$.player.add_track($.mfilenames[$.playing], 1, -1)

			#set mp3 volume relative to global/midi volume
			$.volfactor = 2*y;
			$.setVol( GLOBALVOL )
			sleeptill(Now+1b)
		}
		unlock($)
	}

	method play_handler() {
		#print("play mp3")
		sleeptill(Now+20b)
	}

	method setVol(vol_){
		print("set gst123 volume")
		$.player.setVol( round($.volfactor*vol_) )
	}


	method delete(){
		#stop file
		verbose("Pause gst123")
		$.player.pause(1)
		deleteobject($.player)
	}
}
