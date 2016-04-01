#################################################
# Handle TUIO Messages of MMTT or KinectGrid
# (MMTT=MultiMultiTouchTouch aka Space Palette)
#################################################

# Including submodules
#include contrib/GridMusic/kinect_functions.k
#include contrib/GridMusic/oscplayer.k
#include contrib/GridMusic/gst123.k
#include contrib/GridMusic/area_bpm.k
#include contrib/GridMusic/area_channelswitcher.k
#include contrib/GridMusic/area_drum.k
#include contrib/GridMusic/area_gst123.k
#include contrib/GridMusic/area_systemcalls.k
#include contrib/GridMusic/area.k
#include contrib/GridMusic/area_knob.k
#include contrib/GridMusic/area_multimode.k
#include contrib/GridMusic/area_piano.k
#include contrib/GridMusic/area_playmidi.k
#include contrib/GridMusic/area_setting_switcher.k
#include contrib/GridMusic/area_stepfile.k
#include contrib/GridMusic/area_trumpet.k
#include contrib/GridMusic/area_phrases.k
#include contrib/GridMusic/area_volume.k
#include contrib/GridMusic/oscplayer.k
#include contrib/GridMusic/sender.k

# Including settings and definitions of area groups.
#include contrib/GridMusic/settings.k
#include contrib/GridMusic/mysettings.k

# Other approach for settings storage without this bag of global variables.
# unused
function setting_kinect(){
	return([
	"unused" = -1
	])
}


############### MAIN CLASS ####################

# This loop wait on TUIO messages and call the update handler
# of one area.
# OLD
#function looperX(areas, kstore) {
#	if ( nargs() < 1 ){
#		areas = setting3(0)
#	}
#	if ( nargs() < 2 ){
#		kstore = []
#	}
#	if( typeof(areas) != "array" || typeof(kstore) != "array" ){
#		print("looper: Input has wrong format!")
#		return()
#	}
#
#	#init some global variables....
#	if( !defined(GLOBALVOL) ) GLOBALVOL = 80
#	if( !("clipboard" in kstore) ) kstore["clipboard"] = []
#	if( !("record" in kstore) ) kstore["record"] = ''
#	if( !("record_starttime" in kstore) ) kstore["record_starttime"] = Now
#	kstore["record_active"] = 0
#
#	#start osc looper
#	sleeptill(Now+2b)
#	verbose("STARTING OSC TEST LOOPER...")
#	if ( OSCPORT <= 0 ) {
#		print("Hey, OSCPORT needs to be set")
#		#OSCPORT = 3335
#		return()
#	}
#
#	kstore["looper"] = new osc_looper(OSCPORT, areas)
#	KSTORE = kstore
#
#	GridMusic_run = 1
#
#	#if( defined(LOWKEY) ){
#	if( Graphics == 0 ){
#		print("Press Ctrl+C to exit.")
#		while ( GridMusic_run ) {
#			sleeptill(Now+20b)
#		}
#	}else{
#		print("Press Esc to exit.")
#		while ( GridMusic_run ) {
#			c = Root.waitforconsolekey()
#			if ( ascii(c) == 27 ) {
#				break
#			}
#			print("ignoring c=",c)
#			sleeptill(Now+2b)
#		}
#	}
#
#	#clean up
#	deleteobject(kstore["looper"])
#	for( i in kstore["clipboard"]) deleteobject(kstore["clipboard"][i])
#	KSTORE = []
#}

## Listener for OSC port
class osc_looper {
	method init(OSCPORT, areas) {

		#load setting for hand areas of mmtt
		#$.areas = setting4(0)
		#funcname = printf("setting%i",setting_nbr)#works only for $.methodname
		#$.areas = (funcname)()
		$.areas = areas
		$.areas_size = sizeof($.areas);
		$.osctid = -1
		$.osclistenport = OSCPORT
		$.osclistenhost = "0.0.0.0"

		$.oscf = open($.getHost(),"rA","osc_listen")
		if ( $.oscf < 0 ) {
			print("Unable to listen on ",Osclisten," !?")
		} else {
			#start loop for mmtt osc messages
			#$.start() 
		}

		$.lastosc = 0

	}

	method getHost(){
		#s = string($.osclistenport)+"@"+Hostname
		#s = string($.osclistenport)+"@127.0.0.1"
		s = string($.osclistenport)+"@"+$.osclistenhost
		return(s)
	}
	method handle_tuio_message(d){
		lock($)
		if ( d[1] == "alive" ){
			#print("alive message")
		}else if ( d[1] == "set" ){
			areaid = d[2]/1000 - 1
			handid = d[2]%1000
			if( areaid < $.areas_size ){
				#print("set message. areaid, handid, x,y,z:", areaid, handid, d[3], d[4], d[5])
				depth = d[5]
				#depth *= 20*depth
				#depth = 3*depth
				if( depth > 1) depth = 1

				#if( typeof($.areas[areaid]) == "object") #high costs?!
				if( $.areas[areaid] != -1)
				#if( areaid in $.areas )
				$.areas[areaid].update(areaid,handid,[0=d[3],1=d[4],2=depth])
			}
		}else if ( d[1] == "fseq" ){
			#print("fseq message")
		}
		unlock($)
	}
	method osctask() {
		while ( (d=get($.oscf)) != Eof ) {
			#print("osctask got d=",d)

			# Bundled OSC messages leads to array structure.
			if( typeof(d[0]) == "array" ){
				dnr = d["elements"]
				# Assume index enumeration 0,1,...
				for( i=0 ; i<dnr ; i++){
					#print( d[i] )
					if( d[i][0] == "/tuio/25Dblb" ){
						$.handle_tuio_message(d[i])
					}
				}
			}else{
				$.handle_tuio_message(d)
			}

			lock($)
			$.lastosc = Now
			unlock($)
		}
	}

	method XXreplace_areas(new_areas){
		for( i in new_areas) {
			tmp = $.areas[i]
			$.areas[i] = new_areas[i]
			deleteobject(tmp)
		}
	}

	method get_areas(){
		return($.areas)
	}

	method set_areas(areas){
		#lock($)#already locked
		$.areas = areas
		verbose("Set areas",$.areas)
		#unlock($)
	}

	method start(){
		if( $.osctid != -1 ){
			verbose("Server already started.")
			return(-1)
		}
		verbose("Listening for OSC on ",$.getHost()," ...")
		$.osctid = task $.osctask()
		return(0)
	}

	method stop(){
		verbose("Kill listening task")
		kill($.osctid)
		$.osctid = -1
		return(0)
	}

	method delete {
		if($.oscf > -1){
			close($.oscf)
		}
		kill($.osctid)

		for( i=0 ; i<$.areas_size ; i++ ){
			verbose("Del area ",i)
			deleteobject($.areas[i])
		}
		$.areas = []
	}
}


class kinect{
	method init(funcname, start){
		LOWKEY=1
		$.areas = []
		$.init_store()
		$.osc_looper = -1

    if( string(funcname) in SETTINGS ){
      handle = SETTINGS[string(funcname)]
    }else{
      handle = -1
    }
		if( typeof(handle) == "function" ){
			verbose("Start configuration %s\n", funcname)
			$.areas = handle(0)
		}else{
			printf("Error! Configuration %s not found.\nDoes SETTINGS variable contain your handler?\n\n", funcname)
		}

		if( nargs() > 1 && start != 0){
			$.start()
		}
	}

	# Global clipboard variable for GridMusic
	method init_store(){
		if( !defined(GLOBALVOL) ) GLOBALVOL = 80
		if( !defined(GridMusic_store) ){
			GridMusic_store = []
			KSTORE = GridMusic_store # old name
		}

		# Reset values
		if( !("clipboard" in GridMusic_store) ) GridMusic_store["clipboard"] = []
		if( !("record" in GridMusic_store) ) GridMusic_store["record"] = ''
		if( !("record_starttime" in GridMusic_store) ) GridMusic_store["record_starttime"] = Now
		GridMusic_store["record_active"] = 0
	}

	method start(){
		# init osc looper at first call
		if( $.osc_looper == -1 ){
			verbose("Create osc listener object...")
			if ( OSCPORT <= 0 ) {
				print("Hey, OSCPORT needs to be set")
				return(-2)
			}
			lock($)
			$.osc_looper = new osc_looper(OSCPORT, $.areas)
			unlock($)
			GridMusic_store["looper"] = $.osc_looper
		}

		# start osc looper
		GridMusic_run = 1
		return($.osc_looper.start())
	}

	method stop(){
		GridMusic_run = 0
		return ($.osc_looper.stop())
	}

	method delete(){
		if( $.osc_looper != -1 ){
			deleteobject($.osc_looper)
		}

		#clean up
		#deleteobject(GridMusic_store["looper"])
		#for( i in GridMusic_store["clipboard"]) deleteobject(GridMusic_store["clipboard"][i])
	}

	method get_areas(){
		return($.areas)
	}
}


########## END MAIN CLASS ####################

# Add phrase to global record
function glob_record(ph){
	if( KSTORE["record"] == '' ){
		KSTORE["record_starttime"]  = Now
		KSTORE["record"] = ph
		return()
	}

	td = Now - KSTORE["record_starttime"]
	ph.time += td
	KSTORE["record"] |= ph
}

function glob_record_test(ph){
	td = 2b
	ph2 = ''
	for( n in ph){
		n.time += td
		ph2 |= n
	}
	return(ph2)
}
function glob_record_test2(ph){
	td = 2b
	ph2 = ph
	ph2.time += td
	return(ph2)
}

