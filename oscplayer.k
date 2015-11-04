# Interface to simple,slow java based osc player.
# Use faster gst123 interface if possible!
class oscplayer{
	method init(mfilenames, volume_area) {

		#connect mp3 panel with volume panel (optional)
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

		$.player = new oscplayer()

		$.update = $.update_handler
		$.play = $.play_handler

		#$.loopid = task $.playloop()
	}

	method update_handler(areaid, handid,x,y,z) {
		ix = rand( $.mfiles_size ) # random
		iy = floor( $.dimY*y)
		iz = floor($.dimZ*z)
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
			verbose("stop mp3")
			#$.player.pause()
			$.player.stop()
		}else{
			$.playing = ix
			verbose("start mp3")
			$.player.start($.mfilenames[$.playing])
			sleeptill(Now+1b)

			#set mp3 volume relative to global/midi volume
			$.volfactor = 2*y;
			$.setVol( GLOBALVOL )
		}
		unlock($)
	}

	method play_handler() {
		#print("play mp3")
		sleeptill(Now+20b)
	}

	method setVol(vol_){
		#print("set mp3 volume")
		$.player.setVol( round($.volfactor*vol_) )
	}


	method delete(){
		#stop file
		verbose("Stop mp3 file")
		$.player.stop()
		deleteobject($.player)
	}
}

function mp3list1(volume_area){
	mfiles = []
	#mfiles[0] ="../mp3/Anneliese.mp3"
	mfiles[1] ="../mp3/Anne3.mp3"
	#mfiles[2] ="../mp3/Test.mp3"

	return( new oscplayer(mfiles,volume_area) )
}
