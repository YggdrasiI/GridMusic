#################################################
# Handle TUIO Messages of MMTT or KinectGrid
# (MMTT=MultiMultiTouchTouch aka Space Palette)
#################################################

#define elif else if

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
##include contrib/GridMusic/tests.k

##include contrib/GridMusic/mysettings.k

VERBOSE = 1 # print some debug messages
OSCPORT = 3335
GLOBALVOL = 80

# midi channel of next played note in some areas.
# See area_piano.k and area_channelswitcher.k
MAINCHANNEL = 1

# Array of function handles to settings.
# A setting represent a set of areas and if your
# kinect detect i.e. 11 touchpads, each setting should
# contains 11 areas.
# See area_setting_switcher.k if you want load an other
# setting on runtime.
SETTINGS = [1=(settingPiano),2=(settingPiano),4=(setting3),5=(setting3),6=(setting3),8=(settingGst),9=(settingGst), 10=(settingHalloween)]

# The variable kstore should be used to share data between areas and the osc looper.
# I.e. to change the area objects.
KSTORE = []

## DEFAULT AREA POSITIONS ####################
# The following settings assume this physical
# position of 11 areas (0-10):
#
# ┏━━━━━┳━━━━━┳━━━━━┓
# ┃  0  ┃     ┃  6  ┃
# ┣━━━━━┫  4  ┣━━━━━┫
# ┃     ┃     ┃     ┃
# ┃  1  ┣━━━━━┫  7  ┃
# ┃     ┃     ┃     ┃
# ┣━━━━━┫  5  ┣━━━━━┫
# ┃     ┃     ┃     ┃
# ┃  2  ┣━━━━━┫  9  ┃
# ┃     ┃     ┃     ┃
# ┣━━━━━┫  6  ┣━━━━━┫
# ┃  3  ┃     ┃ 10  ┃
# ┗━━━━━┻━━━━━┻━━━━━┛
#


################ SETTINGS ####################
# Extend settingExample for your own settings
# and invoke them in keykit's console.

# Setting for
function settingExample(loop){

	notes = [0='c',1='e',2='g']
	durations = [0=1b,1=2b,3=4b]
	min_vol = 30
	max_vol = 128

	piano = new area_piano(notes,durations,min_vol,max_vol)

	areas = [ 0=piano, 1=piano, 2=piano, 3=piano,
	4=piano, 5=piano, 6=piano,
	7=piano, 8=piano, 9=piano, 10=piano ]

	if(nargs() < 1 || loop != 0){
		looper(areas, kstore)
	}
	return(areas)
}


# C-Major pads
#
#  0,vol          7,vol
#         4,d
#   1,c           8,e
#         5,g,g'
#   2,f           9,a
#         6,b
#  3,switcher    10,vol
#
function settingPiano(loop){

	settings = settings_piano()
	settings["durations"] = [0=1b,1=4b,2=8b,3=16b,4=32b,5=32b]
	settings["vol_range"] = ["low" = 50, "high" = 128]

	s2 = durarr('co2')
	s3 = durarr('c')
	s4 = durarr('co4')
	s5 = durarr('co5')

	# Same setting for each pad, but different notes
	settings["notes"] = [0=s3[0],1=s4[0],2=s5[0]]
	piano_c = new area_piano(settings)
	settings["notes"] = [1=s3[1],1=s4[1],2=s5[1]]
	piano_d = new area_piano(settings)
	settings["notes"] = [2=s3[2],1=s4[2],2=s5[2]]
	piano_e = new area_piano(settings)
	settings["notes"] = [3=s3[3],1=s4[3],2=s5[3]]
	piano_f = new area_piano(settings)
	settings["notes"] = [4=s2[4],1=s3[4],2=s4[4]]
	piano_g = new area_piano(settings)
	settings["notes"] = [5=s2[5],1=s3[5],2=s4[5]]
	piano_a = new area_piano(settings)
	settings["notes"] = [6=s2[6],1=s3[6],2=s4[6]]
	piano_b = new area_piano(settings)

	#bpm_area = new area_bpm( 30, 190, 20, 1)
	volume_area = new area_volume( 20, 127, 5)

	kstore = []
	switcher = new area_setting_switcher(kstore,SETTINGS)

	#areas = [0=volume_area, 1=piano_c, 2=piano_f, 3=switcher,  4=piano_d, 5=piano_g, 6=piano_b, 7=volume_area, 8=piano_e, 9=piano_a, 10=volume_area ]
	areas = [0=volume_area, 1=piano_c, 2=piano_f, 3=piano_d,  4=piano_d, 5=piano_g, 6=piano_b, 7=volume_area, 8=piano_e, 9=piano_a, 10=volume_area ]

	if(nargs() < 1 || loop != 0){
		looper(areas, kstore)
	}
	return(areas)
}

# Send OSC commands to gst123 (media player)
# Modify oscplayer.k or gst123.k to
# support other players (which?)
function settingGst(loop){

	files=[ 1="filename.mp3",
	2="filename2.mp3"
	];

	bpm_area = new area_bpm( 30, 190, 20, 1)
	volume_area = new area_volume( 20, 127, 5)

	mp3_1 = new area_gst123([0=files[0],1=files[1]],volume_area )
	mp3_2 = new area_gst123([0=files[0],1=files[1]])
	mp3_4 = new area_gst123([0=files[0],1=files[1]])
	mp3_5 = new area_gst123([0=files[0],1=files[1]])
	mp3_6 = new area_gst123([0=files[0],1=files[1]])
	mp3_8 = new area_gst123([0=files[0],1=files[1]])
	mp3_9 = new area_gst123([0=files[0],1=files[1]])


	files3 = []
	files3[0] = "bachinv1.mid"
	files3[1] = "bachinv2.mid"
	files3[2] = "bachinv3.mid"
	files3[3] = "bachinv4.mid"
	playmidi = new area_playmidi(files3, 1.0)

	kstore = []
	switcher = new area_setting_switcher(kstore,SETTINGS)

	areas = [0=volume_area, 1=mp3_1, 2=mp3_2, 3=switcher, 4=mp3_4, 5=mp3_5, 6=mp3_6, 7=bpm_area, 8=mp3_8, 9=mp3_9, 10=playmidi]

	if(nargs() < 1 || loop != 0){
		looper(areas, kstore)
	}
	return(areas)
}

function settingTest(loop){

	durations = [0=1b,1=4b,2=8b,3=8b,4=8b,5=8b]
	s2 = durarr('co2')
	s3 = durarr('c')
	s4 = durarr('co4')
	s5 = durarr('co5')

	#piano_g = new area_piano([4=s2[4],1=s3[4],2=s4[4]],durations,50,128)
	piano_a = new area_piano([5=s2[5],1=s3[5],2=s4[5]],durations,50,128)
	piano_b = new area_piano([6=s2[6],1=s3[6],2=s4[6]],durations,50,128)
	piano_c = new area_piano([0=s3[0],1=s4[0],2=s5[0]],durations,50,128)
	piano_d = new area_piano([1=s3[1],1=s4[1],2=s5[1]],durations,50,128)
	piano_e = new area_piano([2=s3[2],1=s4[2],2=s5[2]],durations,50,128)
	piano_f = new area_piano([3=s3[3],1=s4[3],2=s5[3]],durations,50,128)

	trumpet_notes = [0='cc4',2='ec4',4='gc4',5='ac4',7='co4c4']
	trumpet = new area_trumpet(trumpet_notes,0,121)
	#trumpet = new area_piano([2=s3[2],1=s4[2],2=s5[2]],durations,50,128)

	#bpm_area = new area_bpm( 30, 190, 20, 1)
	volume_area = new area_volume( 20, 127, 5)

	kstore = []
	switcher = new area_setting_switcher(kstore,SETTINGS)

	#big_area_ids = [0=1,1=2,2=4,3=5,4=6,5=8,6=9]
	#replace_areas = [1=piano_e]
	#knob_area = new area_knob(2,2,kstore, big_area_ids, replace_areas);

	channels = [0=1,1=2,2=3]
	channel_area = new area_channelswitcher(channels,kstore);

	multi_area = new area_multimode(kstore)

	areas = [0=volume_area, 1=piano_c, 2=piano_f, 3=switcher,  4=piano_d, 5=trumpet, 6=piano_b, 7=channel_area, 8=multi_area, 9=piano_a, 10=volume_area ]

	if(nargs() < 1 || loop != 0){
		looper(areas, kstore)
	}
	return(areas)
}

########## END OF SETTINGS ####################


############### MAIN CLASS ####################

# This main loop wait on TUIO messages and call the update handler
# of one area.
function looper(areas, kstore) {
	if ( nargs() < 1 ){
		areas = setting3(0)
	}
	if ( nargs() < 2 ){
		kstore = []
	}
	if( typeof(areas) != "array" || typeof(kstore) != "array" ){
		print("looper: Input has wrong format!")
		return()
	}

	#init some global variables....
	if( !defined(GLOBALVOL) ) GLOBALVOL = 80
	if( !("clipboard" in kstore) ) kstore["clipboard"] = []
	if( !("record" in kstore) ) kstore["record"] = ''
	if( !("record_starttime" in kstore) ) kstore["record_starttime"] = Now
	kstore["record_active"] = 0

	#start osc looper
	sleeptill(Now+2b)
	verbose("STARTING OSC TEST LOOPER...")
	if ( OSCPORT <= 0 ) {
		print("Hey, OSCPORT needs to be set")
		#OSCPORT = 3335
		return()
	}

	kstore["looper"] = new looperobj(OSCPORT, areas)
	KSTORE = kstore

	if( defined(LOWKEY) ){
		print("Press Ctrl+C to exit.")
		while (1) {
			sleeptill(Now+20b)
		}
	}else{
		while (1) {
			c = Root.waitforconsolekey()
			if ( ascii(c) == 27 ) {
				break
			}
			print("ignoring c=",c)
			sleeptill(Now+2b)
		}
	}

	#clean up
	deleteobject(kstore["looper"])
	for( i in kstore["clipboard"]) deleteobject(kstore["clipboard"][i])
	KSTORE = []
}

## Main obj.
class looperobj {
	method init(OSCPORT, areas) {

		#load setting for hand areas of mmtt
		#$.areas = setting4(0)
		#funcname = printf("setting%i",setting_nbr)#works only for $.methodname
		#$.areas = (funcname)()
		$.areas = areas
		$.areas_size = sizeof($.areas);

		$.osclistenport = OSCPORT
		#s = string($.osclistenport)+"@"+Hostname
		#s = string($.osclistenport)+"@127.0.0.1"
		s = string($.osclistenport)+"@0.0.0.0"
		$.oscf = open(s,"rA","osc_listen")
		if ( $.oscf < 0 ) {
			print("Unable to listen on ",Osclisten," !?")
			$.osctid = -1
		} else {
			print("Listening for OSC on ",s," ...")
			#start loop for mmtt osc messages
			$.osctid = task $.osctask()
		}

		$.lastosc = 0

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

