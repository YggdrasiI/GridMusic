# Return struct which stores the settings for area_phrases
function settings_phrases{
	phA = 'e,c,ao2,go2';
	phB = 'c, d, e, f, g, a, b'; phB.type = NOTEON

	set = [
	# Flat stage, just first index of array used.
	# !! Use NOTEON type to allow pressure changes after activation of phrase!
	"phrases1" = [0='+c'],
	#"vol_range1" = ["low"=20, "high"=40],
	"vol_range1" = ["low"=40, "high"=100],

	# Deep stage, y axis used for selection.
	"phrases2" = [0=phA, 1=phB],
	"vol_range2" = ["low"=60, "high"=100],

	# Barrier for entering of stage 1
	"z_depth_limit1" = 0.05,

	# Barrier for entering of stage 2
	"z_depth_limit2" = 0.25,
	
	# Z depth smoothing factor
	"z_smooth" = 0.3,

	# Normalize volume of all phrases, 0 disables
	"normalize_volumes" = 1,

	# Restrict phrases channel on normalize_channel, 0 disables
	"normalize_channel" = 0 ,

	# x axis can define different pitches for stage 1 phrases.
	"pitch_offsets" = [0=-8, 1=0],

	# Minimal distance till next note will be played (in stage 2, [0,1]² plane)
	"minimal_distance" = 0.2 * 0.2, # quadrature for l2-Norm.

	# Segment length for each movement step
	"segment_duration" = 1b,

	# Divide range of slices
	# Only detect slice changes if distance of sublices is > 1.
	# [ range 1 ] [ range 2 ]
	# [ 1  2  3 ] [ 4  5  6 ]
	"subslices" = 3,
	"subslice_minimal_distance" = 2,

	# Multiplicative change of volume during blend out
	"blend_speed" = 0.95
	]

	return(set)
}

class area_phrases{

	method help(parent){
		print("area_phrases help")
		print("")
    print("Area contains two different depth stages.")
    print("Stage 1: Vague tone. This stage should inform the user")
    print("		about the presence of the area. Moreover, the xy-Position")
    print("		can be used to select and pitch the phrases of stage 2.")
    print("Stage 2: Track the midpoint of a hand and play the next note")
    print("		of a pharse if the hand was moved a few units away. The")
    print("		direction of movemend does not count but the speed.")
    print("")
    print("Attention, if you use the NOTEON-notes (suitable for stage 1)")
    print("consider following property:")
    print("NOTEON-notes has no duration. Thus '+c, +e' equals '+c +e'!")
    print("To set time distance use '+c, +et96' or")
    print("ph = 'c e'; ph.type = NOTEON")
		print("")

		for( child in $.inherited() ){
			if( child.classof() == "area" ){
				print( child.help($) )
			}
		}
	}

	# public
	method init( settings ) {
		if( nargs() < 1 ){
			settings = settings_phrases()
		}
		$.settings = settings

		# The depth range [z_depth_limit1, z_depth_limit2] should be mapped
		# on [vol_range1["low"], vol_range1["high"]].
		# But we want select the volume of each note relative. 
		# - vol_range["high"] correlates with 1 and
		# - vol_range["low"] correlates with z_depth_constant1
		# f:[a,b] => [r,s] 
		# f(x) = d * x + c
		# r := vol_min/vol_max, s = vol_max/vol_max = 1
		# d := (s-r)/(b-a), c := -a*d + r
		tmpFrac = float($.settings["vol_range1"]["low"]) / float($.settings["vol_range1"]["high"])
		$.z_depth_factor1 = 1.0 - tmpFrac
		$.z_depth_factor1 /= float($.settings["z_depth_limit2"] - $.settings["z_depth_limit1"] )
		$.z_depth_constant1 = float(-$.settings["z_depth_limit1"] * $.z_depth_factor1) + tmpFrac

		# State constants
		$.STATE_TO_FLAT = 1
		$.STATE_FLAT = 2
		$.STATE_TO_DEEP = 3
		$.STATE_DEEP = 4

		$.blendout = ''

		# Normalize array indizies to 0,...
		phrases1 = copy_array2($.settings["phrases1"])
		phrases2 = copy_array2($.settings["phrases2"])

		$.phrases1_size = sizeof(phrases1)
		$.phrases2_size = sizeof(phrases2)

		# Normalize volume and channels
		nv = integer($.settings["normalize_volumes"])
		nc = integer($.settings["normalize_channel"])
		for( i=0; i<$.phrases1_size; i++){
			if( nv != 0 ){
				phrases1[i] = maximize_volume(phrases1[i], $.settings["vol_range1"]["high"])
			}
			if( nc > 0 ){
				phrases1[i].chan = nc
			}
		}
		for( i=0; i<$.phrases2_size; i++){
			if( nv != 0 ){
				phrases2[i] = maximize_volume(phrases2[i], $.settings["vol_range2"]["high"])
			}
			if( nc > 0 ){
				phrases2[i].chan = nc
			}
		}

		# Put phrases back into stettings object
		$.settings["phrases1"] = phrases1
		$.settings["phrases2"] = phrases2

		$.x_range = sizeof($.settings["pitch_offsets"]) * $.settings["subslices"]
		$.y_range = sizeof($.settings["phrases2"])
		$.z_range = 127 #unused

		# Duplicate some last array values to prevent omit out of bounce errors for x|y|z=1
		l = sizeof( $.settings["phrases1"])
		$.settings["phrases1"][l] = $.settings["phrases1"][l-1]
		l = sizeof( $.settings["phrases2"])
		$.settings["phrases2"][l] = $.settings["phrases2"][l-1]
		l = sizeof( $.settings["pitch_offsets"])
		$.settings["pitch_offsets"][l] = $.settings["pitch_offsets"][l-1]

		$.inherit( new area($.x_range, $.y_range, $.z_range) )

		$.hands = []
		$.hand_timestamps = []
		$.last_refresh = Now

		$.update = $.update_handler
		$.play = $.play_handler

		#$.loopid = -1
		$.loopid = task $.playloop()
	}

	# protected
	method update_handler(areaid, handid, xyz) {
		handid+=1000*areaid
		sx = floor( $.x_range*xyz[0] )
		#iy = floor( $.y_range*xyz[1] )
		#iz = floor( $.z_range*xyz[2] )
		#ix = sx / $.settings["subslices"]
		#ixyz = $.get_ixyz(xyz, $.orientation)

		lock($)

		# Add new hand or get stored hand
		if( !(handid in $.hands) ){
			if( xyz[2] < $.settings["z_depth_limit1"] ){
				unlock($)
				return()
			}
			hand = [ "state" = $.STATE_TO_FLAT,
			"pos" = xyz,
			"sx" = sx,
			"ph" = '', "ph_time" = 0
			]
			$.hands[handid] = hand
		}else{
			hand = $.hands[handid]
		}

		hand["time"] = Now
		z_smooth = hand["pos"][2] + (xyz[2] - hand["pos"][2]) * $.settings["z_smooth"]
		hand["pos"][2] = z_smooth

		# State transitions
		if( hand["state"] == $.STATE_DEEP ){
			# Note: "pos" array will be held constant until threshold is reached

			# Compare positions
			d1 = xyz[0]-hand["pos"][0]
			d2 = xyz[1]-hand["pos"][1]
			if( d1*d1 + d2*d2 > $.settings["minimal_distance"] ){
				hand["play_next_segment"] = 1
				hand["pos"][0] = xyz[0]
				hand["pos"][1] = xyz[1]
				verbose("Update stage 2")
			}

		}else if( hand["state"] == $.STATE_TO_FLAT || hand["state"] == $.STATE_FLAT ){
			if( z_smooth > $.settings["z_depth_limit2"] ){ # z_smooth or raw xyz[2]
				hand["state"] = $.STATE_TO_DEEP

				z2 = hand["pos"][2] * $.z_depth_factor1 + $.z_depth_constant1
				ph = hand["ph"]
				ph.vol *= z2
				$.add_to_blendout( ph )

				hand["ph"] = ''
				# Set phrase to stage 2 phrase
				ix = hand["sx"] / $.settings["subslices"]
				iy = floor( $.y_range*xyz[1] )
				ph = $.settings["phrases2"][iy]
				ph.pitch += $.settings["pitch_offsets"][ix]
				hand["ph_complete"] = ph
				hand["ph_max_time"] = ph.length
				#print("Selection for stage 2:", ix, iy, ph)

				hand["pos"] = xyz
			}else{
				if( abs( hand["sx"]-sx ) >= $.settings["subslice_minimal_distance"] ){
					hand["play_new_slice"] = 1
				}
				hand["sx"] = sx
			}

		}

		# reset counter (till inactivity reached)
		#$.loop_count = 0
		unlock($)
	}

	# protected
	method play_handler() {
		#TODO
		ph_new_to_play = ''
		ph_changes = ''

		lock($)
		for( handid in $.hands ){
			hand = $.hands[handid]
			s = hand["state"]
			#printf("%s %d\n", "State: ", hand["state"])

			# Remove old entries
			if( (Now - hand["time"]) > 2b ){
				verbose("Delete old hand", handid)

				z2 = hand["pos"][2] * $.z_depth_factor1 + $.z_depth_constant1
				ph = hand["ph"]
				ph.vol *= z2
				$.add_to_blendout( ph )

				delete( $.hands[handid] ) # To delete in for loop array is no problem in keykit
				continue
			}

			if( s == $.STATE_DEEP ){
				if( "play_next_segment" in hand ){
					delete( hand["play_next_segment"] )

					# Frist, blend out notes without noteoff complement.
					# Here, they has already the right volume and rescaling is not required.
					ph_old = hand["ph"] { ??.type == NOTEON && ??.vol > 0 }
					verbose("Old notes:", ph_old)
					#ph_old.vol *= 0.8
					#$.add_to_blendout( ph_old )
					ph_old.type = NOTEOFF
					ph_old.time = 0
					ph_new_to_play |= ph_old


					tmp = extract1( hand["ph_complete"], hand["ph_time"], $.settings["segment_duration"])
					ph = tmp["ph"]
					#Increment time
					if( tmp["t"] < hand["ph_max_time"] ){
						hand["ph_time"] = tmp["t"]
					}else{
						hand["ph_time"] = 0
					}

					# Adapt volume
					z2 = hand["pos"][2] * $.z_depth_factor1 + $.z_depth_constant1
					ph.vol *= z2

					hand["ph"] = ph

					ph_changes = filter_notes(ph_changes, ph)
					ph_new_to_play |= ph
				}
			}elif( s == $.STATE_TO_DEEP ){
				hand["state"] = $.STATE_DEEP

			}elif( s == $.STATE_FLAT ){
				ph = hand["ph"]

				if( "play_new_slice" in hand ){
					# Switch phrase pitch

					z2 = hand["pos"][2] * $.z_depth_factor1 + $.z_depth_constant1
					ph = hand["ph"]
					ph.vol *= z2
					$.add_to_blendout( ph )

					delete( hand["play_new_slice"] )

					ph = $.new_note_flat( hand, $.settings["phrases1"][0] )
					#hand["ph"] = ph # redundant

					# Filter out pressure changes for same notes to avoid collision
					ph_changes = filter_notes(ph_changes, ph)
					ph_new_to_play |= ph

				}else{
					# Adapt volume
					z2 = hand["pos"][2] * $.z_depth_factor1 + $.z_depth_constant1
					if( abs(hand["vol_factor"] - z2) * $.settings["vol_range1"]["high"] > 3 ){
						hand["vol_factor"] = z2
						ph.vol *= z2
						#verbose(ph,ph.vol,z2, hand["pos"][2], $.settings["z_depth_limit2"], $.z_depth_factor1, $.z_depth_constant1)

						# Remove new played notes to avoid collision
						ph = filter_notes(ph, ph_new_to_play)
						ph_changes |= ph
					}
				}

			}elif( s == $.STATE_TO_FLAT ){
				# Play notes (mostly noteon-messages)
				ph = $.new_note_flat( hand, $.settings["phrases1"][0] )

				# Filter out pressure changes for same notes to avoid collision
				ph_changes = filter_notes(ph_changes, ph)
				ph_new_to_play |= ph

				hand["state"] = $.STATE_FLAT
			}
		}
		unlock($)

		# blending phrases
		$.remove_from_blendout(ph_new_to_play)
		ph_changes |= $.get_blendout($.settings["blend_speed"])

		if( sizeof(ph_new_to_play) > 0 ){
			verbose("play", ph_new_to_play)
		}

		# Change type to pressure
		ph_changes = pressure(ph_changes)

		# Finally, play notes
		realtime( ph_changes | ph_new_to_play, Now)

		sleeptill(Now+32)

	}

	# private, used in play task
	method new_note_flat( hand, ph ){

		# Add pitch offset
		ix = hand["sx"] / $.settings["subslices"]
		ph.pitch += $.settings["pitch_offsets"][ix]

		# Save value without volume changes
		hand["ph"] = ph

		# Adapt volume
		z2 = hand["pos"][2] * $.z_depth_factor1 + $.z_depth_constant1
		hand["vol_factor"] = z2
		ph.vol *= z2

		return(ph)
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
		ph = ph { ??.type == NOTE || ??.type == NOTEON }
		ph = ph { ??.vol > 0 }
		ph.type = NOTEON
		ph.time = 0
		$.blendout |= ph
	}

	# Return current blendout varible
	# and decrease volume of stored values by damping_factor. (1=> no damping)
	# private
	method get_blendout(damping_factor){
		lock($)
		#($.blendout).vol *= damping_factor
		ph = $.blendout
		ph.vol *= damping_factor
		$.blendout = ph
		#ret = $.blendout
		# Note that rounding errors leads to 
		#    ph.vol * x = ph.vol
		# for x nearby 1 and vol nearby 0.
		# Thus, we filter out silent notes
		noteoff = $.blendout { ??.vol < 30 }
		$.blendout = $.blendout { ??.vol >= 30 }
		ret = $.blendout
		noteoff.vol = 0
		ret = ret | noteoff
		unlock($)
		return(ret)
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

	method delete(){
		lock($)
		kill($.loopid) 
		unlock($)

		#noteoff messages
		ph_off=''
		for( handid in $.hands ){
			hand = $.hands[handid]
			ph = hand["ph"]
			ph.vol = 0
			ph_off |= ph
		}
		#verbose("Note off message:", ph_off)
		ph_off |= $.get_blendout(0.0)
		realtime(ph_off,Now)
	}
}

