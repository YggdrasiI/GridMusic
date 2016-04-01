# Send midi commands to switch midi instrument of current bank.
# (Implemtation of knob class)

function settings_instrumentswitcher{
	set = [
	# Channel to change
	"channel" = 1, # keykit channel 1 = midi channel 0

	# Available instruments
	"instruments" = [0=1, 1=2, 2=3],

	# Phrase which will be played if channel was switched.
	# Use '' to mute.
	# Use function handler to create phrase dynamically.
	"phrase" = 'go2,go3',

	# Flag to enable cycling from last to first element.
	"cycle" = 1,

	# You can define different increments for the position
	# of the hand.
	# I.e. use -1 on the left side to go backward and +1 on the right side
	# to go forward in the list of instruments.
	"push_increments" = [0=-1, 1=1],

	# 0, 1. Defines which dimension (x,y) should be used to
	# select the used slice.
	"direction_index" = 0
	]

	base_set = settings_knob()
	extend_array(base_set, set)
	return(base_set)
}

class area_instrumentswitcher{

	method help(parent){
		print("area_instrumentswitcher help")
		print("")
		print("Send midi commands to switch midi instrument of current bank.")
		print("")
		print("Implementation of area_knob class.")
		for( child in $.inherited() ){
			if( child.classof() == "area_knob" ){
				print( child.help($) )
			}
		}
	}

	method init(settings) {
		if( nargs() < 1 ){
			settings = settings_instrumentswitcher()
		}
		$.settings = settings
		$.instruments = copy_array2(settings["instruments"])
		if( sizeof($.instruments) < 1 ) $.instruments=[0=1]
		$.cur_chan_index = 0
		$.direction_index = $.settings["direction_index"]

		grid_dims = [0=1, 1=1]
		grid_dims[$.direction_index] = sizeof($.settings["push_increments"])
		$.settings["dimX"] = grid_dims[0]
		$.settings["dimY"] = grid_dims[1]
		$.settings["handler"]["push_on"] = $.push_handler
		$.settings["handler"]["push_off"] = $.push_handler
		$.inherit( new area_knob($.settings) )
	}

	method push_handler(areaid, handid, xyz){
		dir_index = floor( $.dim[$$.direction_index]*xyz[$$.direction_index])
		dir_value = $.settings["push_increments"][dir_index]

		next_chan_index = ($$.cur_chan_index + dir_value)
		if( $.settings["cycle"] ){
			next_chan_index = next_chan_index % sizeof($$.instruments)
			if( next_chan_index < 0 ){
				next_chan_index += sizeof($$.instruments)
			}
		}else{
			next_chan_index = limit(0, next_chan_index, sizeof($$.instruments))
		}
		$$.cur_chan_index = next_chan_index

		channel = $.settings["channel"]
		index = $$.instruments[$$.cur_chan_index]
		ph_change = change_instrument(channel-1, index)
		verbose("Change instrument of channel ", channel, "to", index)
		realtime(ph_change, Now)
		$$.play_switch_phrase()

		return(0)
	}

	# Parse and play phrase to indicate change.
	method play_switch_phrase(){
		ph = $.settings["phrase"]
		if( typeof(ph) == "function" ){
			ph = ph()
		}
		realtime(ph, Now)
	}

	method delete(){

	}
}
