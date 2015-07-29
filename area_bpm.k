# set bpm with horizontal movement
class area_bpm{
	method init(bpm_min, bpm_max, bpm_stepsize, relative) {

		$.bpm_min = bpm_min
		$.bpm_stepsize = bpm_stepsize
		N = round(bpm_max-bpm_min)/bpm_stepsize
		$.bpm_max = bpm_min + $.bpm_stepsize * N

		$.inherit( new area(N,1,10) )

		$.maxdepth = 0
		$.bpm_ = -1 
		$.bpm_set = ( 60/( float(tempo( ))/1000000) )
		$.update = $.update_handler
		$.play = $.play_handler

		$.relative = 0
		if( nargs() > 3) $.relative = relative

		$.loopid = task $.playloop()
	}

	# relative changing: left=slower right=faster, but bounded
	method update_handler(areaid, handid, xyz) {
		if( handid > 1 ) return();
		ix = floor( $.dimX*xyz[0])
		iy = floor( $.dimY*xyz[1])
		iz = floor( $.dimZ*xyz[2])

		if( iz < 1 ) return();
		lock($)

		if( $.relative == 0){
			bpm_ = $.bpm_min + $.bpm_stepsize*ix
		}else{
			if( xyz[0]<0.5 && $.bpm_set>$.bpm_min ){
				bpm_ = $.bpm_set*0.95
			}else if( $.bpm_set<$.bpm_max){
				bpm_ = $.bpm_set/0.95
			}else{
				bpm_ = $.bpm_set
			}

		}

		# select bpm_ with max depth value in the time intervall  
		if( $.maxdepth < iz ){
			$.bpm_ = bpm_
			$.maxdepth = iz
		}
		unlock($)
	}

	method play_handler() {
		if( $.bpm_ > 0 ){
			lock($)
			verbose("Set bpm to", $.bpm_)
			$.bpm_set = bpm($.bpm_)
			$.bpm_ = -1
			$.maxdepth = -1
			unlock($)
		}
		sleeptill(Now+1b)
	}

}
