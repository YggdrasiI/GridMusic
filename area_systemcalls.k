#
# Invoke bash script
#
class area_systemcalls{
	method init( volume_area) {

		#connect this object with volume panel (optional)
		if( nargs() > 0 ){
			volume_area.addListener( $, "setVol" )
		}

		$.volfactor = 1.0 # relative volume

		#number of files (well, the list of files was moved into the bash script)
		$.mfiles_size = 10

		$.hand_is_in = 0
		$.playing = -1

		#first dim: file
		#second dim: volume
		#thrird dim: trigger 0/>1
		$.inherit( new area($.mfiles_size,2,10) )

		$.cmd_start = "./play.sh "
		$.cmd_stop = "killall mplayer"
		$.cmd_vol = "some amixer stuff"

		$.update = $.update_handler
		$.play = $.play_handler

		#$.loopid = task $.playloop()

		#Test
		test = sprintf("%s %d", $.cmd_start, 10)
		system(test)
	}

	method update_handler(areaid, handid, xyz) {
		ix = rand( $.mfiles_size ) # random
		iy = floor( $.dimY*xyz[1])
		iz = floor($.dimZ*xyz[2])
		lock($)
		if( iz < 1 ) $.hand_is_in = 0

		if(0 && $.playing > -1 ){
			$.volfactor = 2*xyz[1];
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
			verbose("send stop cmd")
			system($.cmd_stop)
		}else{
			$.playing = ix
			verbose("send start cmd ", $.playing)
			system($.cmd_start)

			#set mp3 volume relative to global/midi volume
			$.volfactor = 2*xyz[1];
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
		print("send volume cmd")
		#$.player.setVol( round($.volfactor*vol_) )
		#todo
	}


	method delete(){
		#stop file
		verbose("Send stop cmd on delete")
		system($.cmd_stop)
	}
}
