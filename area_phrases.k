# 2015, TODO
# Area contains two different depth stages.
# Stage 1: Vague tone. This stage should inform the uses
#			about the presence of the area. Moreover, the xy-Position
#			can be used to select and pitch the phrases of stage 2.
# Stage 2: Track the midpoint of a hand and play the next note
#			of a pharse if the hand was moved a few units away. The
#			direction of movemend does not count but the speed.
#

# Struct which stores the settings for area_phrases
class settings_phrases{

	# public
	method init(){
		# Flat stage, just first index used.
		$.phrases1 = [0='c']
		$.vol_range1 = ["low"=20, "high"=40]

		# Deep stage, y axis used for selection.
		$.phrases2 = [0='e', 1='c,d,e,f,g,a,b']
		$.vol_range2 = ["low"=60, "high"=127]

		# Barrier from stage 1 to 2.
		$.z_depth_limit = 0.25

		# Factor for linear tranformation on vol_range1
		$.z_depth_factor1 = float($vol_range[1]-$.vol_range[2])/$.z_depth_limit

		# Normalize volume of all phrases, 0 disables
		$.normalize_volumes = 1

		# Restrict phrases on channel, 0 disables
		$.normalize_channel = 0 

		# x axis defines can define different pitches stage 2 phrases.
		$.pitch_offsets = [0=-3, 1=0, 2=0, 3=3]

		# Minimal distance till next note will be played (in stage 2, [0,1]² plane)
		$.minimal_distance = 0.2 * 0.2 # quadrature for l2-Norm.

		# Segment length for each movement step
		$.segment_duration = 1b

		# Divide range of slices
		# Only detect slice changes if distance of sublices is > 1.
		# [ range 1 ] [ range 2 ]
		# [ 1  2  3 ] [ 4  5  6 ] 
		$.subslices = 3
		$.subslice_minimal_distance = 2
	}
}

class area_phrases{

	# public
	method init( settings ) {
		$.settings = settings

		# State constants
		$.STATE_TO_FLAT = 1
		$.STATE_FLAT = 2
		$.STATE_TO_DEEP = 3
		$.STATE_DEEP = 4

		$.phrases1_size = sizeof($.phrases_stage_1)
		$.phrases2_size = sizeof($.phrases_stage_2)

		# Normalize array indizies to 0,...	
		phrases1 = copy_array2($.settings.phrases1)
		phrases2 = copy_array2($.settings.phrases2)

		# Normalize volume and channels
		nv = integer($.settings.normalize_volumes)
		nc = integer($.settings.normalize_channel)
		for( i= $.phrases_stage_1_size; i>0; i--){
			if( nv != 0 ){
				$.phrases1[i] = maximize_volume($.phrases1[i], $.settings.vol_range1["high"])
			}
			if( nc > 0 ){
				$.phrases1[i].chan = nc
			}
		}
		# Put phrases back into stettings object
		$.settings.phrases1 = phrases1
		$.settings.phrases2 = phrases2

		$.x_range = sizeof($.settings.pitch_offsets) * $.settings.subslices
		$.y_range = sizeof($.settings.phrases2)
		$.z_range = 127 #unused

		$.inherit( new area($.x_range, $.y_range, $.z_range) )

		$.hands = []
		$.hand_timestamps = [] 
		$.last_refresh = Now

		$.update = $.update_handler
		$.play = $.play_handler

		$.loopid = task $.playloop()
	}

	# protected
	method update_handler(areaid,handid,x,y,z) {
		handid+=1000*areaid
		sx = floor( $.x_range*x )
		#iy = floor( $.y_range*y )
		#iz = floor( $.z_range*z )
		#ix = sx / $.settings.subslices

		lock($)

		# Add new hand or get stored hand
		if( !(handid in $.hands) ){
			hand = [ "state" = $.STATE_TO_FLAT,
			"pos" = [0=x,1=y,2=z],
			"sx" = sx,
			"ph" = '', "ph_time" = 0, 
			"time" = Now 
			]
			$.hands[handid] = hand
		}else{
			hand = $.hands[handid]
		}


		# State transitions
		if( hand["state"] == $.STATE_DEEP ){
			# Note: "pos" array will be held constant until threshold is reached

			# Compare positions
			d1 = x-hand["pos"][0]
			d2 = y-hand["pos"][1]
			if( d1*d1 + d2*d2 > $.settings.minimal_distance ){
				hand["play_next_segment"] = 1
				hand["pos"][0] = x
				hand["pos"][1] = y
			}

		}else if( hand["state"] in [$.STATE_TO_FLAT, $.STATE_FLAT] ){

			if( z > $.settings.z_depth_limit ){
				$.add_to_blendout( hand["ph"] )
				hand["state"] = $.STATE_TO_DEEP
				hand["pos"] = [0=x,1=y,2=z]
			}else{
				if( abs( hand["sx"]-sx ) >= $.settings.subslice_minimal_distance ){
					hand["play_new_slice"] = 1
				}
				hand["sx"] = sx
				z_smooth = hand["pos"][2]*0.7 + z*0.3
				hand["pos"] = [0=x,1=y,2=z_smooth] # depth value required in flat state
			}

		}

		# reset counter (till inactivity reached)
		#$.loop_count = 0
		unlock($)
	}

	# protected
	method play_handler() {
		#TODO
		lock($)
		ph_new_to_play = ''
		ph_changes = ''

		for( hand in $.hands ){
			s = hand["state"]
			if( s == $.STATE_DEEP ){
			}elif( s == $.STATE_TO_DEEP ){
			}elif( s == $.STATE_FLAT ){
				ph = hand["ph"]

				if( "play_new_slice" in hand ){
					# Switch phrase pitch

					delete( hand["play_new_slice"] )
					$.add_to_blendout(ph)

					ph = $.new_note_flat( hand, $.settings.phrases1[0] )

					# Filter out pressure changes for same notes to avoid collision
					ph_changes = filter_notes(ph_changes, ph)
					ph_new_to_play |= ph

				}else{
					# Adapt volume 
					z2 = hand["pos"][2] * $.settings.z_depth_factor1 + $.settings.vol_range1[0] 
					ph.vol *= z2  

					# Remove new played notes to avoid collision
					ph = filter_notes(ph, ph_new_to_play)
					ph_changes |= ph
				}

			}else( s == $.STATE_TO_FLAT ){
				# Play notes (mostly noteon-messages)
				ph = $.new_note_flat( hand, $.settings.phrases1[0] )

				# Filter out pressure changes for same notes to avoid collision
				ph_changes = filter_notes(ph_changes, ph)
				ph_new_to_play |= ph
			}
		}

		# blending phrases
		$.remove_from_blendout(ph_new_to_play)
		ph_changes |= $.get_blendout(0.9)

		unlock($)

		# Change type to pressure 
		ph_changes = pressure(ph_changes)

		# Finally, play notes
		realtime( ph_changes | ph_new_to_play, Now)

		sleeptill(Now+10)

	}

	# private, used in play task 
	method new_note_flat( hand, ph ){

		# Add pitch offset
		ix = hand["sx"] / $.settings.subslices
		ph.pitch += $.settings.pitch_offsets[ix] 

		# Save value without volume changes
		hand["ph"] = ph

		# Adapt volume 
		z2 = hand["pos"][2] * $.settings.z_depth_factor1 + $.settings.vol_range1[0] 
		ph.vol *= z2 

		return(ph)
	}

	method get_note(){
		lock($)

		tmp = extract1( $.data["file"],$.data["timestamp"],$.testdur)
		note = tmp[0]
		$.data["timestamp"] = tmp[1]
		#print("note: ", note,"    noteduration: ", note.dur)
		verbose("noteduration: ", note.dur)

		if( $.data["timestamp"] >= $.data["maxtimestamp"] ){
			$.data["timestamp"] = 0
		}

		unlock($)
		note.vol *= 1.5
		#note.time = 0
		note.chan = 1
		return(note)
	}

	# I.E. to add some decorations
	# private
	method modify_note(note){
		return( note+major(note)  )
	}

	# Extend blendout varible by new notes
	# The note types in $.blendout should be Noteon
	# and should converted into pressure later, if used.
	# private
	method add_to_blendout(ph){
		lock($)
		ph = ph { ??.type == NOTE || ??.type == NOTEON }
		ph.type = NOTEON
		ph.time = 0
		$.blendout |= ph
		unlock($)
	}

	# Return current blendout varible
	# and decrease volume of stored values by damping_factor. (1=> no damping)
	# private
	method get_blendout(damping_factor){
		lock($)
		$.blendout *= damping_factor
		$.blendout = $.blendout { ??.vol > 0 }
		unlock($)
		return($.blendout)
	}

	# To remove notes from blendout which
	# played again.
	# private
	method remove_from_blendout(ph){
		lock($)
		$.blendout = filter_notes( $.blendout, ph ) 
		unlock($)
	}

	# Generate phrase for hands in flat state
	# private
	method get_noteFLAT(){
		lock($)
		unlock($)
	}

	# Generate phrase for hands in deep state
	# private
	method get_noteDEEP(){
		lock($)
		unlock($)
	}

}

