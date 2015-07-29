# Simple class to play one note. 
# xyz Orientation defines note, volume and duration.
# The input (movement) and output (sending midi) are
# sperated into two tasks. (Avoid blocking of output.)

# Return struct which stores the settings for area_piano
function settings_piano{
	default_notes = [0='c',1='d',2='e',3='f',4='g',5='a',6='b',7='co4']
	default_durations = [0=1b,1=4b,2=8b,3=16b,4=32b,5=32b]
	default_vol_range = ["low" = 30, "high" = 100]
	default_orientation = [0=0,1=2,2=1]

	set = [
	# Notes for slices
	"notes" = default_notes,

	# Durations for above notes
	"durations" = default_durations,

	# Volume range
	"vol_range" = default_vol_range,

	# Mapping of (x,y,z) onto (notes,durations,vol_range)
	"orientation" = default_orientation
	]
	return(set)
}

class area_piano{
	#method init(notes, durations, vol_min, vol_max) {
		method init( settings ) {
			if( nargs() < 1 ){
				settings = settings_piano()
			}
			$.settings = settings

			$.notes = copy_array2(settings["notes"])
			$.possible_notes_size = sizeof($.notes)
			# Repeation of last element for internal reasons
			$.notes[$.possible_notes_size] = $.notes[$.possible_notes_size-1]

			$.durations = copy_array2(settings["durations"])
			$.durations_size = sizeof($.durations)
			# Repeation of last element for internal reasons
			$.durations[$.durations_size] = $.durations[$.durations_size-1]

			$.orientation = settings["orientation"]

			$.vol_min = settings["vol_range"]["low"]
			$.vol_max = settings["vol_range"]["high"]
			$.vol_range = vol_max-vol_min

			$.inherit( new area($.possible_notes_size,$.durations_size,$.vol_range) )

			$.loop_beats = 2b
			$.loopdur = $.durations[0]
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

		method update_handler(areaid, handid, xyz) {
			lock($)
			ix = floor( ($.possible_notes_size)*xyz[0])
			iy = floor( ($.dimY)*xyz[2])
			iz = floor($.dimZ*xyz[1])
			note = $.notes[ ix  ]
			note.vol = $.vol_min + iz
			#note.vol = 100
			#print("Volume = ", note.vol )
			note.dur = $.durations[ iy ]
			#print("Note.chan = ",note.chan )
			#$.loop_beats = $.durations[ iz ]
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
			if( xyz[2]<0.05 ){
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
				sleeptill(Now+20)
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
			#note.chan = MAINCHANNEL
			#note.vol *= GLOBALVOL/128.0
			return(note)
			ph = major(note)
			ph.vol *= 0.3
			return( note|ph  )
			#		return( major(note) )
		}
	}
