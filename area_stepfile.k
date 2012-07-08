# Similar to piano class.
# Play n-th note of given midi file instead of arbitary note.
# stepfile_data is a function handler (see bottom).
class area_stepfile{
	method init(possible_notes, speeds, vol_min, vol_max, stepfile_data, prime_note) {

		$.data = stepfile_data
		$.possible_notes = copy_array2(possible_notes)
		$.possible_notes_size = sizeof($.possible_notes)

		$.speeds = copy_array2(speeds)
		$.speeds_size = sizeof($.speeds)-1

		$.vol_min = vol_min
		$.vol_max = vol_max	
		$.vol_range = vol_max-vol_min

		$.inherit( new area($.possible_notes_size,$.speeds_size,$.vol_range) )

		if( nargs() > 5  && typeof(prime_note) == "array" ){
			$.prime_note = copy_array2(prime_note)
			pns = sizeof($.prime_note)
			for( i= $.possible_notes_size - pns; i>0; i--){
				$.prime_note[pns-1+i] = $.prime_note[pns-1]
			}
		}else{
			$.prime_note = -1
		}

		$.loop_beats = 2b
		$.loopdur = $.speeds[0]
		$.loop_count = 0
		$.hands = []
		$.htimestamps = []

		$.last_seq = Now
		$.sequenz = ''

		$.update = $.update_handler
		$.play = $.play_handler

		$.testdur = 1b/2
		$.toplay = 0
		$.lastix = 0

		$.loopid = task $.playloop()
	}

	method update_handler(areaid,handid,x,y,z) {
		handid+=1000*areaid
		lock($)
		ix = floor( ($.possible_notes_size)*x)
		iy = floor( ($.speeds_size)*z)
		iz = floor($.vol_range*y)
		note = $.possible_notes[ ix  ]
		note.vol = $.vol_min + iz
		#note.vol = 100
		note.dur = $.speeds[ iy ]
		#print("Note.chan = ",note.chan )
		#$.loop_beats = $.speeds[ iz ]

		$.lastix = ix

		# reset
		#if(z>0.5) $.testfile_beat = 0;

		#if( $.hands[handid] == "" || ( note.pitch != ($.hands[handid]).pitch && Now-$.htimestamps[handid]>20 ))
		if( !(handid in $.hands) || ( note.pitch != ($.hands[handid]).pitch && Now-$.htimestamps[handid]>20 )){
			$.htimestamps[handid] = Now
			$.toplay += 1
		}
		#if( $.blocktimes[handid] < Now )
			# select maximal volume reached in the time intervall (till $.hands is reset) 
			#if( $.hands[handid] != "" && $.hands[handid].vol > note.vol )
			if( (handid in $.hands) && $.hands[handid].vol > note.vol ){
				note.vol = $.hands[handid].vol
				$.hands[handid] = note
			}else{
				$.hands[handid] = note
			}
		#

		# reset counter (till inactivity reached)
		$.loop_count = 0
		#print("area update done. Indizes:", ix, iy, iz)
		unlock($)
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
			#	print("Play sequenz")
		}

		#if( sizeof($.hands) > 0 ){}
		#while( $.toplay > 0 ){}
		if( $.toplay > 0 ){
			note = $.get_note()
			lock($)
			#clear note
			#$.hands = []
			#$.toplay -= 1
			$.toplay = 0

			#modifiy note if prime_note is set.
			if( $.prime_note != -1 ){
				verbose("Shift: ",$.lastix,", ", $.prime_note[$.lastix], ".")
				note.pitch = $.prime_note[$.lastix].pitch
			}

			unlock($)

			# mit Now sind verschiedene Haende nicht ganz syncron
			verbose("Play note", note)
			realtime(note, Now)
		}
		sleeptill(Now+10)
	}

	method get_note(){
		lock($)

		tmp = extract1( $.data["file"],$.data["timestamp"],$.testdur)
		note = tmp[0]
		$.data["timestamp"] = tmp[1]
		#print("note: ", note,"    noteduration: ", note.dur)
		verbose("noteduration: ", note.dur)

		if( $.data["timestamp"] > $.data["maxtimestamp"] ){
			$.data["timestamp"] = 0
		}

		unlock($)
		note.vol *= 1.5
		#note.time = 0
		return(note)
	}

	method modify_note(note){
		return( note+major(note)  )
		#		return( major(note) )
	}
}

# share some data between stepfile classes of two areas. I.E. current timestamp
function stepfile_data(filename){
	data = []
	data["file"] = readmf(filename)
	data["maxtimestamp"] = data["file"].time
	data["timestamp"] = 0
	return(data)
}
