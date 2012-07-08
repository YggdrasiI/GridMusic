# Simple class to play one note. 
## Speed hat Einfluss auf die Realzeit-Dauer einer Musikschleife. Einheit?!
class area_piano{
	method init(possible_notes, speeds, vol_min, vol_max) {

		$.possible_notes = copy_array2(possible_notes)
		$.possible_notes_size = sizeof($.possible_notes)
		$.possible_notes[$.possible_notes_size] = $.possible_notes[$.possible_notes_size-1]

		$.speeds = copy_array2(speeds)
		$.speeds_size = sizeof($.speeds)
		$.speeds[$.speeds_size] = $.speeds[$.speeds_size-1]

		$.vol_min = vol_min
		$.vol_max = vol_max	
		$.vol_range = vol_max-vol_min

		$.inherit( new area($.possible_notes_size,$.speeds_size,$.vol_range) )

		$.loop_beats = 2b
		$.loopdur = $.speeds[0]
		$.loop_count = 0
		$.hands = []
		$.xis = []

		$.last_seq = Now
		$.sequenz = ''
		$.last_note = ''
		$.last_refresh = Now

		$.update = $.update_handler
		$.play = $.play_handler

		$.loopid = task $.playloop()
	}

	method update_handler(areaid,handid,x,y,z) {
		lock($)
		ix = floor( ($.possible_notes_size)*x)
		iy = floor( ($.speeds_size)*z)
		iz = floor($.vol_range*y)
		note = $.possible_notes[ ix  ]
		note.vol = $.vol_min + iz
		#note.vol = 100
		#print("Volume = ", note.vol )
		note.dur = $.speeds[ iy ]
		#print("Note.chan = ",note.chan )
		#$.loop_beats = $.speeds[ iz ]
		# i f( $.blocktimes[handid] < Now )
		if( $.xis[handid] != ix ){
			#$.hands[handid] = ""
			$.xis[handid] = ix
			$.last_note = ''
		}

		# select maximal volume reached in the time intervall (till $.hands is reset) 
		if( $.hands[handid] != "" && $.hands[handid].vol > note.vol ){
			note.vol = $.hands[handid].vol
			$.hands[handid] = note
			$.xis[handid] = ix
		}else{
			$.hands[handid] = note
		}

		$.last_refresh = Now
		if( z<0.05 ){
			$.clear()
		}

		# reset counter (till inactivity reached)
		$.loop_count = 0
		#print("area update done. Indizes:", ix, iy, iz)
		unlock($)
	}

	# clear last note, if hand was moved back. This allows playing the last played note again.
	method clear(){
		$.last_note = ''
		$.hands = []
	}

	method play_handler() {
		if(Now - $.last_seq > $.loop_beats && $.loop_count>0){
			lock($)
			sequenz = $.sequenz
			$.last_seq = Now
			$.sequenz = ''
			$.loop_count -= 1
			unlock($)

			#				realtime(sequenz, Now)
			#	print("Play sequence")
		}

		if( sizeof($.hands) > 0 ){
			lock($)
			note = $.get_note()
			# remove notes of the last tick

			#noteb = note - $.last_note
			#ignore volume differences
			noteb = filter_notes(note,$.last_note)
			#noteb = note

			$.last_note = note
			$.sequenz += noteb
			#clear notes
			$.hands = []
			unlock($)

			#print("Play note", noteb)
			# mit Now sind verschiedene Areas nicht ganz syncron
			ph = $.modify_note(noteb)
			realtime( ph, Now)
			if(KSTORE["record_active"]) glob_record( ph ) 
			#sleeptill(Now+noteb.dur)
			#sleeptill(Now+20)
			sleeptill(Now+10)
		}else{
			if( Now - $.last_refresh > 46 ){
				lock($)
				$.clear()
				$.last_refresh = Now+1b
				unlock($)
			}
			#sleeptill(Now+10)
			sleeptill(Now+1)
		}
	}

	method get_note(){
		note = ''
		for( n in $.hands ){
			note |= $.hands[n]
		}
		return(note)
	}

	method modify_note(note){
		note.chan = MAINCHANNEL
		#note.vol *= GLOBALVOL/128.0
		return(note)
		ph = major(note)
		ph.vol *= 0.3
		return( note|ph  )
		#		return( major(note) )
	}
}
