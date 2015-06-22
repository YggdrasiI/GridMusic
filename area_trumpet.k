# Play one note/hand with very long duration.
# Needs midi instrument, which consides .dur-property, like trumpet. 
# The hand depth controls the volume. The volume will be set to 0 if
# the hand leaves the area.
#
# Check if your midi controller can react on volume change messages.
# Otherwise it does not work.
# Option in zynaddsubfx: Serach for "Vol" in the controller window
#
class area_trumpet{
	method init(possible_notes, vol_min, vol_max) {

		$.DFADE_OUT = 1 #constant 
		$.FFADE_OUT = 0.8 #scalar
		$.hands = [] # store active hands
		$.count_hand = [] # store nbr of hands in range of notes.
		$.active_hand = [] # store active hand for a note

		$.possible_notes = copy_array2(possible_notes)
		$.possible_notes_size = sizeof($.possible_notes)
		$.possible_notes[$.possible_notes_size] = $.possible_notes[$.possible_notes_size-1]

		for( i in $.possible_notes){
			n = $.possible_notes[i]
			n.dur = 10b #depratced
			n.type = NOTEON
			$.possible_notes[i] = n
			$.active_hand[i] = -1
			$.count_hand[i] = 0
		}

		$.vol_min = vol_min
		$.vol_max = vol_max	
		$.vol_range = vol_max-vol_min

		$.inherit( new area(3*$.possible_notes_size,1,$.vol_range) )


		$.update = $$.update_handler2
		$.play = $.play_handler

		$.loopid = task $.playloop()
	}

	method update_handler2(areaid,handid,x,y,z) {
		#lock($)
		z *= 2
		if( z>1) z = 1
		ix = floor( $.dimX*x )
		iz = floor($.dimZ*z )#vol
		#iz = floor($.dimZ*z*3 )#vol
		#if(iz>$.vol_range) iz = $.vol_range
		#inote = integer(ix/3)
		inote = floor(ix/3)

		#if( handid in $.hands )
		if( $.hands[handid] != "" ){
			hand = $.hands[handid]
			# modify old note
			if( Now - hand["tstamp"] > 10) {
				oin = hand["inote"] #old index of note
				if( abs(ix - hand["ix"]) > 1 && inote != oin ){
					# deaccociate hand from note
					$.count_hand[oin]--
					if($.active_hand[oin] == handid) $.active_hand[oin] = -1 

					if($.count_hand[oin]<1){
						# Send noteoff message 
						note = $.possible_notes[oin]
						note.vol = 0
						verbose("(trumpet) Mute previous note", handid, oin)
						realtime(note,Now)
					}

					# accociate hand with new note
					$.count_hand[inote]++
					if($.active_hand[inote] == -1){
						$.active_hand[inote] = handid
						note2 = $.possible_notes[ inote ]
						note2.vol = $.vol_min + iz
						$.possible_notes[inote] = note2
						verbose("(trumpet) Update note",handid, inote, note2.vol)
						realtime(note2,Now)
					}
					hand = ["inote"=inote,"ix"=ix,"tstamp"=Now]
					$.hands[handid] = hand

				}else if( $.active_hand[oin] == handid ){
					#change volume
					note = $.possible_notes[oin]
					dv = limit(-8,$.vol_min + iz - note.vol,8)
					#dv = $.vol_min + iz - note.vol
					if( dv != 0 ){
						note.vol += dv
						$.possible_notes[oin] = note
						press = pressure(note) 
						verbose("(trumpet) Change volume to",handid, inote, note.vol)
						#if(note.vol > 120)print("MAX!!!!!!")
						realtime(press,Now)
					}
				}
				hand["tstamp"] = Now
			}
		}else{
			# New hand
			note = $.possible_notes[inote]
			note.vol = $.vol_min + iz
			verbose("(trumpet) Play new hand", inote, note.vol)
			realtime(note,Now)
			hand = ["inote"=inote,"ix"=ix,"tstamp"=Now]
			$.hands[handid] = hand
			$.count_hand[inote]++
			if($.active_hand[inote] < 0) $.active_hand[inote] = handid
		}
		#unlock($)
	}

	# find leaved hands and decrease velocity
	# remove them, if they very silent.
	method play_handler() {
		lock($)
		for( handid in $.hands ){
			if( $.hands[handid] != "" ){
				if( Now - $.hands[handid]["tstamp"] > 1b ){
					# Fade out note if hand is the active one
					# and there is no other hand.
					inote = $.hands[handid]["inote"]
					note = $.possible_notes[inote]
					if($.active_hand[inote] == handid){
						$.active_hand[inote] = -1
					}
					if($.count_hand[inote] < 2 ){
						# This and is the only hand for this note.
						# Fade out note and release 
						note.vol *= $.FFADE_OUT
						note.vol -= $.DFADE_OUT
						if( note.vol < $.DFADE_OUT){
							note.vol = 0
							realtime(note,Now)
							$.count_hand[inote]--
							verbose("Mute ", handid, inote, note.vol)
							delete($.hands[handid])
						}else{
							$.possible_notes[inote] = note
							verbose("Fade out ", handid, inote, note.vol)
							press = pressure(note)
							realtime(press,Now)
						}
					}else{
						# Note is controled by other hand. Remove this hand immediately.
						$.count_hand[inote]--
						verbose("Mute ", handid, inote, note.vol)
						delete($.hands[handid])
					}
				}
			}
		}
		unlock($)
		sleeptill(Now+46)
	}

	method delete(){
		kill($.loopid)
		#noteoff messages
		ph=''
		for( i in $.possible_notes ){
			n = $.possible_notes[i]
			n.vol = 0
			ph+=n
		}
		realtime(ph,Now)
	}

}
