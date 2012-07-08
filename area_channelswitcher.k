# Loop through array of channel numbers for MAINCHANNEL
# (Implemtation of knob class)

class area_channelswitcher{

	method init(channels, kstore) {
		if( typeof(channels) != "array" ){
			print("First argument needs to be an array!")
			channels = []
		}
		$.channels = copy_array2(channels)
		if( sizeof($.channels) < 1 ) $.channels=[0=1]
		$.cur_chan_index = 0

		handler = ["push_on"=$.push_handler,"push_off"=$.push_handler]
		$.inherit( new area_knob(1,1,kstore, handler, [], []) )
		#$.push_on = $$.push_handler
		#$.push_off = $$.push_handler # same event
	}

	method push_handler(areaid, handid, x,y,z){
		if( typeof(MAINCHANNEL) != "integer" ){
			print("Warning, MAINCHANNEL was no integer.")
			#return()
		}
		$$.cur_chan_index = ($$.cur_chan_index + 1)%sizeof($$.channels)
		MAINCHANNEL = $$.channels[$$.cur_chan_index]
		verbose("Change main channel to", MAINCHANNEL,".")
		return(1)
	}

	method delete(){

	}
}
