# set global (midi) volume
class area_volume{
	method init(vol_min, vol_max, vol_stepsize) {
		p = gvolchange( integer(GLOBALVOL) )
		realmidi(p)

		$.vol_min = vol_min
		$.vol_stepsize = vol_stepsize
		N = round(vol_max-vol_min)/vol_stepsize
		$.vol_max = vol_min + $.vol_stepsize * N

		$.inherit( new area(N,1,10) )

		# allow listening (for method setVol)
		$.inherit( new sender() )

		$.maxdepth = 0
		$.vol_ = -1

		$.update = $.update_handler
		$.play = $$.play_handler

		$.loopid = task $.playloop()
	}

	method update_handler(areaid, handid, xyz) {
		if( handid > 1 ) return();
		ix = floor( $.dim[0]*xyz[0])
		iy = floor( $.dim[1]*xyz[1])
		iz = floor( $.dim[2]*xyz[2])
		lock($)
		vol_ = $.vol_min + $.vol_stepsize*ix

		# select vol_ with max depth value in the time intervall
		if( $.maxdepth < iz ){
			$.vol_ = vol_
			$.maxdepth = iz
		}
		unlock($)
		print("area_volume: update handler.")
	}

	method play_handler() {
		if( $.vol_ > 0 ){
			if( $.vol_ != GLOBALVOL || 1){ # this if causes problems...
				lock($)
				verbose("Set vol to", $.vol_)
				p = gvolchange( integer($.vol_) )
				realmidi(p)
				GLOBALVOL = $.vol_

				#propagate volume change to listener
				$.notify($.vol_)

				$.vol_ = -1
				$.maxdepth = -1
				unlock($)
				sleeptill(Now+16)
			}else{
				sleeptill(Now+4)
			}
		}else{
			sleeptill(Now+16)
		}
	}
}
