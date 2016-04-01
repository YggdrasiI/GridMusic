# Loop through array of channel numbers for MAINCHANNEL
# (Implemtation of knob class)

function settings_channelswitcher{
	set = [
	# Available channels
	"channels" = [0=1, 1=2, 2=3],

	# Phrases which will be played if channel was switched. 
	# phrase1 will not modified, but the channel of pharase2
	# represents the current active MAINCHANNEL.
	# Use '' to mute.
	# Use function handler to create phrase dynamically.
	"phrase1" = 'co2',
	"phrase2" = 'co3',

	# Flag to enable cycling from last to first element.
	"cycle" = 1,

	# Directions. You can define different increments for the position 
	# of the hand. 
	# I.e. use -1 on the left side to go back and +1 on the right side.
	"directions" = [0=-1, 1=1],

	# 0, 1. Defines which dimension (x,y) should be used to
	# select one of the direction.
	"direction_index" = 0
	]

	base_set = settings_knob()
	extend_array(base_set, set)
	return(base_set)
}

class area_channelswitcher{

	method help(parent){
		print("area_channelswitcher help")
		print("")
		print("Cycle value of MAINCHANNEL.")
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
			settings = settings_channelswitcher()
		}
		$.settings = settings
		$.channels = copy_array2(settings["channels"])
		if( sizeof($.channels) < 1 ) $.channels=[0=1]
		$.cur_chan_index = 0
		$.direction_index = $.settings["direction_index"]

		grid_dims = [0=1, 1=1]
		grid_dims[$.direction_index] = sizeof($.settings["directions"])
		$.settings["dimX"] = grid_dims[0]
		$.settings["dimY"] = grid_dims[1]
		$.settings["handler"]["push_on"] = $.push_handler
		$.settings["handler"]["push_off"] = $.push_handler
		$.inherit( new area_knob($.settings) )

		if( typeof(MAINCHANNEL) != "integer" ){
			print("(area_channelswitcher) Warning, class changes global variable MAINCHANNEL,")
			print(" but it is no integer.")
		}
	}

	method push_handler(areaid, handid, xyz){
		dir_index = floor( $.dim[$.direction_index]*xyz[$.direction_index])
		dir_value = $.settings["directions"][dir_index]

		next_chan_index = ($$.cur_chan_index + dir_value)
		if( $.settings["cycle"] ){
			next_chan_index = next_chan_index % sizeof($$.channels)
			if( next_chan_index < 0 ){
				next_chan_index += sizeof($$.channels)
			}
		}else{
			next_chan_index = limit(0, next_chan_index, sizeof($$.channels))
		}
		$$.cur_chan_index = next_chan_index
		
		MAINCHANNEL = $$.channels[$$.cur_chan_index]
		verbose("Change main channel to", MAINCHANNEL,".")


		return(1)
	}

	# Parse and play phrase to indicate change.
	method play_switch_phrase(){
		ph1 = $.settings["phrase1"]
		if( typeof(ph1) == "function" ){
			ph1 = ph1()
		}
		ph2 = $.settings["phrase2"]
		if( typeof(ph2) == "function" ){
			ph2 = ph2()
		}
		ph2.chan = MAINCHANNEL
		realtime(ph1|ph2, Now)
	}

	method delete(){

	}
}
