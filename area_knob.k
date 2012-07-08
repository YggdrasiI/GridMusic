# Abstract class for knob.
# replace_ids can define areaids which will replaced by this object or the objects in replace_areas.
#  The active areas in the osc looper will replaced it the knob is active.
# There are four events:
# - Area activated/push_on (any hand)
# - Area deactivated/push_off (any hand)
# - Area released (any hand)
# - (optional, if area pushed) other Area selected
#
# Example for replacing:
# replace_ids = [0=1,1=3,2=5]
# replace_areas = [3=A1, 5=A2]
# => areas[1] will replaced with $, areas[3] with A1 and area[5] with A2
#
#
# Attention: The line	$.replace_areas[id] = $ 
# in the knob contructor has a pitfall. If you inherit and call knobs
# init() $ points to the knob object. To avoid this set up the replace_areas
# array before you call area_knob's init().
#
#
# Implemtations of knob class:
# area_channelswitcher
# area_multimode
###########################################


class area_knob{
	method init(dimX, dimY, kstore, handler, replace_ids, replace_areas) {
		$.inherit( new area(dimX,dimY,5) )
		$.active = 0
		$.pushed = 0
		$.lastid = -1
		$.knobid = -1
		$.last_refresh_time = -1
		$.kstore = kstore

		if(nargs() < 6){
			replace_areas = []
		}
		if(nargs() < 5){
			$.replace_ids = []
			$.replace_areas = []
		}else{
			$.replace_ids = replace_ids
			$.replace_areas = replace_areas
			for( i in $.replace_ids ){
				id = $.replace_ids[i]
				if( typeof($.replace_areas[id]) != "object" ){
				#if( id in $.replace_areas )
					print("sollte nicht erreicht werden.")
					$.replace_areas[id] = $  # $$, not $! Das ist hier aber nicht mgl.
				}
			}
		}

		$.update = $.update_handler
		#$.push_on = $$.default_push_handler
		#$.push_off = $$.default_push_handler
		#$.release = $$.default_release_handler

		if( nargs() < 4 ){
			handler = []
		}
		
		if( typeof(handler["select"]) == "function" ) $.select = handler["select"]
		else $.select = $.default_select_handler
		if( typeof(handler["release"]) == "function" ) $.release = handler["release"]
		else $.release = $.default_release_handler
		if( typeof(handler["push_on"]) == "function" ) $.push_on = handler["push_on"]
		else $.push_on = $.default_push_handler
		if( typeof(handler["push_off"]) == "function" ) $.push_off = handler["push_off"]
		else $.push_off = $.default_push_handler
		if( typeof(handler["replace"]) == "function" ) $.replace = handler["replace"]
		else $.replace = $.default_replace_handler
		if( typeof(handler["restore"]) == "function" ) $.restore = handler["restore"]
		else $.restore = $.default_restore_handler
		
	}

	method update_handler(areaid,handid,x,y,z) {
		#ix = floor( ($.dimX)*x )
		#iy = floor( ($.dimY)*z )
		iz = floor( ($.dimZ)*z )
		td = Now-$.last_refresh_time;
#		lock($)
		if( $.pushed == 1 && ((iz < 2 && td > 1b && areaid == $.lastid) || td > 3b ) ){
			#change push flag if last pushed area is leaved or some time elapsed
			$.pushed = 0
			if( $.lastid == $.knobid ){
				$$.release($.knobid, handid, x,y,z) #attention, handid matching in general to areaid, not knobid.
				#$.last_refresh_time = Now
			}
		}

		if( iz > 2 ){
			if( areaid != $.lastid && td>48 ) $.pushed = 0

			if( $.pushed == 0 ){
				$.pushed = 1
				$.lastid = areaid
				if( $.knobid == -1 || $.knobid == areaid){
					#the knob is pushed.
					if( $.active == 0){
						if( $$.push_on(areaid, handid, x,y,z) ){
							$.active = 1
							# Save id of this area
							$.knobid = areaid
							$$.replace()
						}
					}else{
						if( $$.push_off(areaid, handid, x,y,z)){
							$$.restore()
							$.active = 0
							$.knobid = -1
						}
					}
				}else{
					#an other area pad invoked is pushed.
					#print("Select area !", areaid, " Knob is ", $.knobid);
					verbose("Select area !", areaid, $, $$);
					realtime('do1c12v128', Now)
					$$.select(areaid,handid,x,y,z)
				}
			}
		}

		if( areaid == $.lastid ){
			$.last_refresh_time = Now
		}
#		unlock($)
	}

	# replace areas with $ 
	method default_replace_handler(){
		verbose("Replace areas", $, $$)
		areas = $.kstore["looper"].get_areas()
		for( i in $.replace_ids ){
			if( $.knobid != $.replace_ids[i]){
				swap($.replace_areas, $.replace_ids[i], areas, $.replace_ids[i])
			}
		}
	}

	# replace $ with backuped areas
	method default_restore_handler(){
		verbose("Restore areas")
		areas = $.kstore["looper"].get_areas()
		for( i in $.replace_ids ){
			if( $.knobid != $.replace_ids[i]){
				swap($.replace_areas, $.replace_ids[i], areas, $.replace_ids[i])
			}
		}
	}

	method default_push_handler(areaid, handid, x,y,z){
		if( !$.active ){
			verbose("Knob activated (default handler).", areaid)
			realtime('co3v128d200', Now)
		}else{
			verbose("Knob deactivated (default handle).", areaid)
			realtime('co2v128d200', Now)
		}
		return(1)
	}

	method default_release_handler(areaid, handid, x,y,z){
		verbose("Knob released (default handler).")
	}

	method default_select_handler(areaid,handid,x,y,z){
		verbose("Area ",areaid," selected. (default handler)");
		realtime('go2v128d100', Now)
	}


	method delete(){
		verbose("delete of knob called.", $);
		#lock($)
		#delete replaced areas, too.
		#This objects should not destroied here?!
		deletesubitems($,$.replace_areas)
		#unlock($)
	}

}#end class area_knob

