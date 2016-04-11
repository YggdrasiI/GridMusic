### Abstract class for knob. Could be used for triggers, etc.
function settings_knob{
	set = [
	# Horizontal number of slices
	"dimX" = 1,
	# Vertical number of slices
	"dimY" = 1,

	# Indizies for function handler:
	# push_on, push_off, release, select (, replace, restore)
	# See help text for more information.
	"handler" = [],

	# Ids and objects for area replacement.
	# See help text for more information.
	"replace_ids" = [],
	"replace_areas" = []
	]
	return(set)
}

class area_knob{

	method help(parent){
		if( nargs() < 1 ){
			print("area_knob help")
			print("")
			print("Abstract class for knob. Could be used for triggers, etc.")
			print("")
			print(" Four different events will be handled:")
			print(" - push_on: Knob activated with push on area X (=:knobid) ")
			print(" - push_off: Second push in areas[knobid] (arbitary hand).")
			print(" - release: Hand leaves areas[knobid] (arbitary hand).")
			print(" - select: Push event on areas with id != knobid. (optional, see note for replacing areas)")
			print("")
			print(" Replacing Areas")
			print(" If you want spread the functionality of the knob on multiple areas (i.e. some kind of selection task) you can use the replace_* arguments.")
			print(" - replace_ids: Define area ids which will replaced by this object")
			print("                or the objects in replace_areas.")
			print("                The active areas in the osc looper will replaced if the knob is active.")
			print(" - replace_areas: Array with objectes for replacing task.")
			print("")
			print(" Example for replacing:")
			print("  replace_ids = [0=1, 1=3, 2=5]  ; Replacing of area 1, area 3 and area 5.")
			print("  replace_areas = [3=A1, 5=A2]   ; Area 3 object will be replaced by A1.")
			print("                                 ; Area 5 object will be replaced by A2.")
			print("                                 ; Area 1 object implicit replaced by $.")
			print("")
			print(" Attention: The line	")
			print("  $.replace_areas[id] = $")
			print("  in the knob contructor has a pitfall. If you inherit this class and call knob's")
			print("  init() method, $ points to the knob object, but not $$.")
			print("  To avoid this problem set up the replace_areas array before you call area_knob's init(),")
			print("  see area_multimode.init().")
			print("")
			print(" Implementations of knob class:")
			print(" area_channelswitcher")
			print(" area_multimode")
			print("")
		}

		for( child in $.inherited() ){
			if( child.classof() == "area" ){
				print( child.help($) )
			}
		}
	}

	#method init(dimX, dimY, handler, kstore, replace_ids, replace_areas) {
	method init(settings){
		if( nargs() < 1 ){
			settings = settings_knob()
		}
		$.settings = settings
		$.inherit( new area($.settings["dimX"], $.settings["dimY"], 5) )
		# Flag is 1 if push_on returned 1 (which fires replace handler)
		$.active = 0
		# Flag if a hand pushed an area. This could be an arbitary tracked area.
		$.pushed = 0
		# Id of last pushed area
		$.lastid = -1
		# Id where active flag was set
		$.knobid = -1
		# Timestamp of last push
		$.last_pushed_time = -1

		# Removed. No good Idea store this locally.
		#if( ! ("looper" in $.settings)
		#	&& typeof(GridMusic_store) == "array"
		#	&& "looper" in GridMusic_store
		#){
		#	$.settings["looper"] = GridMusic_store["looper"]
		#}

		rids = $.settings["replace_ids"]
		for( i in rids ){
			id = rids[i]
			if( typeof(rids[id]) != "object" ){
				print("(area_knob) This line should not be reached. Update your usage of this class.")
				# Pitfall: We need $$ here, not $! Unfortunately we can not
				# reference $$ here.
				$.settings["replace_areas"][id] = $ 
			}
		}

		$.update = $.update_handler

		handler = $.settings["handler"]
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

	method update_handler(areaid, handid, xyz) {
		iz = floor($.dim[2]*xyz[2])
		td = Now-$.last_pushed_time;
		#		lock($)
		if( $.pushed == 1 && ((iz < 2 && td > 1b && areaid == $.lastid) || td > 3b ) ){
			#change push flag if last pushed area is leaved or some time elapsed
			$.pushed = 0
			$.last_pushed_time = Now
			if( $.lastid == $.knobid ){
				$$.release($.knobid, handid, xyz) #attention, handid matching in general to areaid, not knobid.
			}
		}

		if( iz > 2 ){
			# Forget old activation pushes at other area.
			if( areaid != $.lastid && td>2b ) $.pushed = 0

			if( $.pushed == 0 ){
				$.pushed = 1
				$.last_pushed_time = Now
				$.lastid = areaid
				if( $.knobid == -1 || $.knobid == areaid){
					#the knob is pushed.
					if( $.active == 0){
						if( $$.push_on(areaid, handid, xyz) ){
							$.active = 1
							# Save id of this area
							$.knobid = areaid
							$$.replace()
						}
					}else{
						if( $$.push_off(areaid, handid, xyz)){
							$$.restore()
							$.active = 0
							$.knobid = -1
						}
					}
				}else{
					#an other area pad was is pushed.
					#print("Select area !", areaid, " Knob is ", $.knobid);
					verbose("(area_knob) Select area !", areaid, $, $$);
					#realtime('do1c12v128', Now)
					$$.select(areaid, handid, xyz)
				}
			}
		}

		if( areaid == $.lastid && $.pushed > 0){
			#$.last_pushed_time = Now
		}
		#		unlock($)
	}

	# replace areas with $
	method default_replace_handler(){
		if( !"looper" in GridMusic_store ){
			verbose("(area_knob) Replace areas. No looper object defined.")
			return()
		}
		verbose("(area_knob) Replace areas")

		areas = GridMusic_store["looper"].get_areas()
		rids = $.settings["replace_ids"]
		ras = $.settings["replace_areas"]
		for( i in rids ){
			if( $.knobid != rids[i]){
				swap(ras, rids[i], areas, rids[i])
			}
		}
	}

	# restore backuped areas
	method default_restore_handler(){
		if( !"looper" in GridMusic_store ){
			verbose("(area_knob) Restore areas skiped. No looper object defined.")
			return()
		}
		verbose("(area_knob) Restore areas")

		areas = GridMusic_store["looper"].get_areas()
		rids = $.settings["replace_ids"]
		ras = $.settings["replace_areas"]
		for( i in rids ){
			if( $.knobid != rids[i]){
				swap(ras, rids[i], areas, rids[i])
			}
		}
	}

	# Return 1 if pushing should influence internal state of this object.
	method default_push_handler(areaid, handid, xyz){
		if( !$.active ){
			verbose("(area_knob) Knob activated (default handler).", areaid)
			#realtime('co3v128d200', Now)
		}else{
			verbose("(area_knob) Knob deactivated (default handler).", areaid)
			#realtime('co2v128d200', Now)
		}
		return(1)
	}

	method default_release_handler(areaid, handid, xyz){
		verbose("(area_knob) Knob released (default handler).")
		#realtime('go2v128d100', Now)
	}

	method default_select_handler(areaid, handid, xyz){
		verbose("(area_knob) Area ",areaid," selected. (default handler)");
		#realtime('go2v128d100', Now)
	}


	method delete(){
		verbose("(area_knob) delete of knob called.");
		#lock($)
		#delete replaced areas, too.
		#This objects should not destroied here?!
		deletesubitems($,$.settings["replace_areas"])
		#unlock($)
	}

}#end class area_knob

