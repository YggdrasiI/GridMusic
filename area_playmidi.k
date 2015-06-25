class area_playmidi{
	method init(mfilenames, volfactor) {

		$.volfactor = 1.0
		if( nargs() > 1){
			$.volfactor = volfactor
		}

		#load midi files
		$.mfiles = []
		i = 0
		for( n in mfilenames ){
			$.mfiles[i] = readmf(mfilenames[n]);
			# Reduce channels (Test)
			$.mfiles[i] = reduce_channels($.mfiles[i], 4);
			i+=1
		}
		$.mfiles_size = sizeof($.mfiles)	

		$.hand_is_in = 0
		$.playing = -1
		$.mt = -1 # play task
		$.rt = -1 # repeat task
		$.xt = -1

		#first dim: file
		#second dim: stop OR play, play&repeat
		#thrird dim: trigger 0/>1
		$.inherit( new area($.mfiles_size,2,10) )

		$.update = $.update_handler
		$.play = $.play_handler

		#$.loopid = task $.playloop()
	}

	method update_handler(areaid,handid,x,y,z) {
		ix = floor( ($.mfiles_size)*x)
		iy = floor( $.dimY*y)
		iz = floor($.dimZ*z)
		#print("depth: ",z,iz)
		if( iz < 1 ) $.hand_is_in = 0
		if( iz < 2 || $.hand_is_in > 0 ) return()
		lock($)
		$.hand_is_in = 1
		if( $.playing > -1 ){
			kill($.rt)
			kill($.mt)
			$.playing = -1
			verbose("stop midi")
		}else{
			$.playing = ix
			verbose("start midi")
			kill($.rt)
			kill($.mt)		# stop playing of previous one
			kill($.xt)

			if( iy > 0 ){
				$.rt = task $.repeat_current()
			}else{
				$.xt = task $.play_current($.mfiles[$.playing].length)
			}

			#$.playfile = normalize($.mfiles[$.playing],-1,$.volfactor*GLOBALVOL)
			$.playfile = normalize($.mfiles[$.playing],-1,$.volfactor)
			$.mt =	realtime($.playfile)
		}
		unlock($)
	}

	method play_handler() {
		verbose("play midi")
		sleeptill(Now+10b)
	}

	method play_current(wait){
		sleeptill(Now + wait)
		#probably redundant
		kill($.mt)
		# allow start of new file with one gesture
		$.hand_is_in = 0
		$.playing = -1
	}

	method repeat_current(){
		d = $.mfiles[$.playing].length
		#if( d > 1000b) d = 1000b
		sleeptill( Now + d )
		#print("repeat midi")
		kill($.mt)		# stop playing of previous one
		$.mt = realtime($.playfile)
		# Start new repeat task
		$.rt = task $.repeat_current()
	}


	method delete(){
		kill($.xt)
		kill($.rt)
		kill($.mt)
	}
}

class area_playmidi_random {
	method init(mfilenames, volfactor) {

		$.volfactor = 1.0
		if( nargs() > 1){
			$.volfactor = volfactor
		}

		$.mfilenames = []
		i = 0
		for( n in mfilenames ){
			$.mfilenames[i] = mfilenames[n];
			i+=1
		}
		$.mfiles_size = sizeof($.mfilenames)	

		$.hand_is_in = 0
		$.playing = -1
		$.mt = -1 # play task
		$.rt = -1 # repeat task
		$.xt = -1

		#first dim: file
		#second dim: stop OR play, play&repeat
		#third dim: trigger 0/>1
		$.inherit( new area($.mfiles_size,2,10) )

		$.update = $.update_handler
		$.play = $.play_handler

		#$.loopid = task $.playloop()
	}

	method update_handler(areaid,handid,x,y,z) {
		ix = rand( $.mfiles_size ) # random
		iy = floor( $.dimY*y)
		iz = floor($.dimZ*z)
		#print("depth: ",z,iz)
		if( iz < 1 ) $.hand_is_in = 0
		if( iz < 2 || $.hand_is_in > 0 ) return()
		lock($)
		$.hand_is_in = 1
		if( $.playing > -1 ){
			kill($.rt)
			kill($.mt)
			$.playing = -1
			verbose("stop midi")
		}else{
			$.playing = ix
			verbose("start midi")
			kill($.rt)
			kill($.mt)		# stop playing of previous one
			kill($.xt)

			#load midi files
			$.mfile = readmf($.mfilenames[$.playing])
			$.mfile = normalize($.mfile,-1,$.volfactor*GLOBALVOL)

			#$.mfile = change_channels($.mfile,4)

			if( iy > 0 ){
				$.rt = task $.repeat_current()
			}else{
				$.xt = task $.play_current($.mfile.length)
			}

			$.mt =	realtime($.mfile)
		}
		unlock($)
	}

	method play_handler() {
		#print("play midi")
		sleeptill(Now+10b)
	}

	method play_current(wait){
		sleeptill(Now + wait)
		#probably redundant
		if( $.mt > -1 ){ kill($.mt) }
		# allow start of new file with one gesture
		$.hand_is_in = 0
		$.playing = -1
	}

	method repeat_current(){
		d = $.mfile.length
		#if( d > 1000b) d = 1000b
		sleeptill( Now + d )
		#print("repeat midi")
		kill($.mt)		# stop playing of previous one
		$.mt = realtime($.mfile)
		# Start new repeat task
		$.rt = task $.repeat_current()
	}


	method delete(){
		kill($.xt)
		kill($.rt)
		kill($.mt)
	}
}

# Implementation of area_playmidi_random
function drums{
	mfiles = []
	mfiles[0] ="drums/12bar1.mid"
	mfiles[1] ="drums/12bar4.mid"
	mfiles[2] ="drums/12bar6.mid"
	mfiles[3] ="drums/12bar7.mid"
	mfiles[4] ="drums/Blues10.mid"
	mfiles[5] ="drums/Blues2.mid"
	mfiles[6] ="drums/Blues7.mid"
	mfiles[7] ="drums/Jazz1.mid"
	mfiles[8] ="drums/Jazz12.mid"
	mfiles[9] ="drums/Jazz5.mid"
	mfiles[10] ="drums/Latin9.mid"
	mfiles[11] ="drums/Latin6.mid"
	mfiles[12] ="drums/Latin39.mid"
	mfiles[13] ="drums/Latin29.mid"
	mfiles[14] ="drums/Latin24.mid"
	mfiles[15] ="drums/Latin21.mid"
	mfiles[16] ="drums/Latin2.mid"
	mfiles[17] ="drums/Latin15.mid"
	mfiles[18] ="drums/Latin34time1.mid"
	mfiles[19] ="drums/Latin68time1.mid"
	mfiles[20] ="drums/Rock3.mid"
	mfiles[21] ="drums/Rock30.mid"
	mfiles[22] ="drums/Rock33.mid"
	mfiles[23] ="drums/Rock42.mid"
	mfiles[24] ="drums/Rock49.mid"
	mfiles[25] ="drums/Rock7.mid"
	mfiles[26] ="drums/Rock13.mid"
	mfiles[27] ="drums/Rock16.mid"
	mfiles[28] ="drums/Rock20.mid"
	mfiles[29] ="drums/Rock26.mid"
	mfiles[30] ="drums/folk1.mid"
	mfiles[31] ="drums/folk13.mid"
	mfiles[32] ="drums/folk18.mid"
	mfiles[33] ="drums/folk30.mid"
	mfiles[34] ="drums/folk33.mid"
	mfiles[35] ="drums/folk34.mid"
	mfiles[36] ="drums/folk38.mid"
	mfiles[37] ="drums/folk42.mid"
	mfiles[38] ="drums/folk46.mid"
	mfiles[39] ="drums/folk5.mid"
	mfiles[40] ="drums/34time13.mid"
	mfiles[41] ="drums/34time19.mid"
	mfiles[42] ="drums/34time2.mid"
	mfiles[43] ="drums/34time23.mid"
	mfiles[44] ="drums/34time8.mid"
	mfiles[45] ="drums/68time10.mid"
	mfiles[46] ="drums/68time15.mid"
	mfiles[47] ="drums/68time2.mid"
	mfiles[48] ="drums/68time20.mid"
	mfiles[49] ="drums/68time7.mid"
	mfiles[50] ="drums/ethnic11.mid"
	mfiles[51] ="drums/ethnic17.mid"
	mfiles[52] ="drums/ethnic24.mid"
	mfiles[53] ="drums/ethnic28.mid"
	mfiles[54] ="drums/ethnic5.mid"
	mfiles[55] ="drums/world13.mid"
	mfiles[56] ="drums/world18.mid"
	mfiles[57] ="drums/world2.mid"
	mfiles[58] ="drums/world23.mid"
	mfiles[59] ="drums/world7.mid"
	mfiles[60] ="drums/dance19.mid"
	mfiles[61] ="drums/dance21.mid"
	mfiles[62] ="drums/dance28.mid"
	mfiles[63] ="drums/dance3.mid"
	mfiles[64] ="drums/dance34.mid"
	mfiles[65] ="drums/dance4.mid"
	mfiles[66] ="drums/dance42.mid"
	mfiles[67] ="drums/dance47.mid"
	mfiles[68] ="drums/dance49.mid"
	mfiles[69] ="drums/dance8.mid"
	mfiles[70] ="drums/Contemporary10.mid"
	mfiles[71] ="drums/Contemporary16.mid"
	mfiles[72] ="drums/Contemporary27.mid"
	mfiles[73] ="drums/Contemporary33.mid"
	mfiles[74] ="drums/Contemporary38.mid"
	mfiles[75] ="drums/Contemporary4.mid"
	mfiles[76] ="drums/Contemporary41.mid"
	mfiles[77] ="drums/Contemporary46.mid"
	mfiles[78] ="drums/Contemporary48.mid"
	mfiles[79] ="drums/Contemporary7.mid"

	return( new area_playmidi_random(mfiles, 0.6) )
}
