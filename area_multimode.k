# Combine four operations at the edges of a 3x3 grid. This
# is a implementation of the knop class and can be used 
# to record & play loops.
# -------
#  0 | 1
# -------
#  2 | 3
# -------
#    OPERATION					PUSH ORDER
# 0. Copy phrase:   		{this knob} {source area} {target area}
#												If (target==source) the last recorded phrase will copied.
# 1. Record phrase: 		{this knob} {piano area}* {this knob}
# 2. Play/Stop phrase: 	{this knob} {source area}
# 3. Modify phrase: 		{this knob} {source area} {modification}
#


class area_multimode{

	method init(kstore) {
		#map grid cell number to mode
		#$.mode_map = [0=0,1=-1,2=1,3=-1,4=-1,5=-1,6=2,7=-1,8=3]
		piano_areas = pianoPads()
		replace_ids = index_array(piano_areas)
		replace_areas = []
		for( i in replace_ids ){
			replace_areas[replace_ids[i]] = $
		}

		handler = ["push_on"=$.push_handler_on,"push_off"=$.push_handler_off, "select"=$.select_handler,"replace"=$.multi_replace,"restore"=$.multi_restore]
		$.inherit( new area_knob(7,7, kstore, handler, replace_ids, replace_areas) )

		#$.select = $$.select_handler
		#$.push_on = $.push_handler_on
		#$.push_off = $.push_handler_off
		$.piano_areas = piano_areas
		$.mode = -2 #above code set mode in parent class. Thus avoid the usage of this var.
		$.playing_phrases = []
		#reaction time for start/stop playing phrases
		$.playing_phrases_beat_len = 1b

		$.play = $.play_handler
		$.loopid = task $.playloop()

		$.kstore["clipboard"] = []
		$.kstore["clipboard"][99] = new foophrase('co2c12', 1b, 0)
		$.playing_phrases[99] = 1

	}

	method play_handler(){
		lock($)
		#print("play loop (in multiarea)", $, $$)
		#$$.select(1,1,0,0,0)
		ph = ''
		for( i in $$.playing_phrases ){
			#extract next beat of clipboard for foophrase i
			if( $.kstore["clipboard"][i].running() )
			ph |= $.kstore["clipboard"][i].next()
			else
			delete($$.playing_phrases[i])
		}
		#if( ph != '') print("play clipboard phrases", ph)
		realtime(ph)
		sleeptill(Now+$$.playing_phrases_beat_len)
		unlock($)
	}

	method push_handler_on(areaid, handid, xyz){
		ix = floor( $.dim[0]*xyz[0])
		iy = floor( $.dim[1]*xyz[1])
		#$.mode = $.mode_map[$.dim[0]*iy+ix]
		if( ix < 3 ){
			if( iy < 3 ) $.mode = 2
			else if( iy > 3 ) $.mode = 0
		}else if( ix > 3 ){
			if( iy < 3 ) $.mode = 3
			else if( iy > 3 ) $.mode = 1
		}else{
			$.mode = -1
		}
		verbose("Mode: ",$.mode, "Id:", $, $$)
		#$$.mode = $.mode
		realtime('c+o1c12v128', Now)
		if( $.mode < 0 ) return(0)
		if( $.mode == 0 ){
			verbose("Copy mode: Start")
			$.copy_source = -1
			$.copy_target = -1
			#realtime('c')
		}else if( $.mode == 1 ){
			verbose("Record mode: Start")
			$.kstore["record"] = ''
			$.kstore["record_starttime"] = Now
			$.kstore["record_active"] = 1
			#realtime('d')
		}else if( $.mode == 2 ){
			verbose("Play mode: Start")
			#realtime('e')
		}else if( $.mode == 3 ){
			verbose("Modify mode: Start")
			#realtime('f')
		}
		return(1)
	}

	method push_handler_off(areaid, handid, xyz){
		realtime('d+o1c12v128', Now)
		if( $.mode == 0 ){
			verbose("Copy mode: End")
			#realtime('co4v120')
		}else if( $.mode == 1 ){
			verbose("Record mode: End")
			$.kstore["record_active"] = 0
			#realtime('do4v128')
			#realmidi($.kstore["record"])
		}else if( $.mode == 2 ){
			verbose("Play mode: End")
			#realtime('eo4')
		}else if( $.mode == 3 ){
			verbose("Modify mode: End")
			#realtime('fo4')
		}
		return(1)
	}

	method multi_replace(){
		#print("Mode???!: ",$, $$, $.mode, $$.mode)
		if( $.mode == 1 ){
			verbose("Replace areas(2), Piano")
			replace_areas = $$.piano_areas
		}else{
			verbose("Replace areas(2), Normal")
			replace_areas = $.replace_areas
		}
		areas = $.kstore["looper"].get_areas()
		for( i in $.replace_ids ){
			if( $.knobid != $.replace_ids[i] ){
				swap(replace_areas, $.replace_ids[i], areas, $.replace_ids[i])
			}
		}

	}

	method multi_restore(){
		verbose("Restore areas(2)", $, $$)
		if( $.mode == 1 ){
			replace_areas = $$.piano_areas
		}else{
			replace_areas = $.replace_areas
		}
		areas = $.kstore["looper"].get_areas()
		for( i in $.replace_ids ){
			if( $.knobid != $.replace_ids[i] ){
				swap(replace_areas, $.replace_ids[i], areas, $.replace_ids[i])
			}
		}
	}

	method select_handler(areaid, handid, xyz){
		#print("Select handler of multimode", $, $$)
		if( $.mode == 0 ){
			verbose("Copy mode: Select")
			if( $.copy_source > -1 ){
				$.copy_target = areaid
				verbose("Area ",areaid," is target")
				if( $.copy_source != $.copy_target ){
					#copy source to target.
					$.kstore["clipboard"][$.copy_target] = $.kstore["clipboard"][$.copy_source]
				}else{
					#copy "Snarf" to target
					$.kstore["clipboard"][$.copy_target] = new foophrase($.kstore["record"], $$.playing_phrases_beat_len, 1)
					#$.kstore["clipboard"][$.copy_target] = new foophrase($.kstore["record"], 1b, 0)
					realmidi($.kstore["record"])
				}
				#action finished. release knob
				$.active = 0
				$.restore()
				$.knobid = -1
				$.mode = -1
			}else{
				verbose("Area ",areaid," is source")
				$.copy_source = areaid
				#realmidi('ev120')
			}
		}else if( $.mode == 1 ){
			verbose("Record mode: Select")
			verbose("   This should not be called.")
		}else if( $.mode == 2 ){
			verbose("Play mode: Select", $)
			phs = $$.playing_phrases
			if( phs[areaid] == 1 ){
				#stop playing
				verbose("Stop playing")
				delete(phs[areaid])
				#}else if( defined($.kstore["clipboard"][areaid]) ){
			}else if( areaid in $.kstore["clipboard"] ){
				#start playing
				verbose("Start playing")
				$.kstore["clipboard"][areaid].reset(0)
				#$.kstore["clipboard"][areaid].set_loop(0)
				phs[areaid] = 1
			}
			#action finished. release knob
			#$.active = 0
			#$$.restore()
			#$.knobid = -1
			#$.mode = -1
		}else if( $.mode == 3 ){
			verbose("Modify mode: Select")
			print("   Not implemented")
		}

	}

	method delete(){
		kill($.loopid)
		deletesubitems($,$.piano_areas)
		deleteobject($.kstore["clipboard"][99] )
	}
}


################# Some Classes   ##########
class foophrase {
	method init(ph, beat_len, loop){
		$.starttime = Now
		if( nargs() < 3) $.loop = 0
		else $.loop = loop
		if( nargs() < 2) $.beat_len = 1b
		else $.beat_len = beat_len
		if( nargs() < 1) $.ph = 'cv128,e,g'
		else $.ph = ph
		$.beat = 0
		$.length_ = phrase_length($.ph)
		$.maxbeat = -floor(- $.length_/$.beat_len )-1 #ceil(...)-1
	}

	method running(){
		return( $.beat<=$.maxbeat )
	}

	method next(){
		if($.beat>$.maxbeat) return('')
		lock($)
		ret = extract_beat($.ph,$.beat,$.beat_len)
		$.beat++
		if($.beat>$.maxbeat && $.loop) $.beat=0
		unlock($)
		return(ret)
	}

	method set_loop(loop){
		lock($)
		$.loop = loop
		if($.beat>$.maxbeat && $.loop) $.beat=0
		unlock($)
	}

	method reset(){
		lock($)
		$.beat = 0
		unlock($)
	}

}
