#include contrib/GridMusic/start.k

enable_output()
LOWKEY=1

# ----------------------------------------------

# Minimal test to check if Keykit <=> Synthesiszer
# connection work. If yes, it should be played
# a simple chord.
# Startup order:
#		1. Synthesiser (lowkey)
#		2. Keykit (lowkey)
#		3. Connect both program externally
#   4. Start test
function basetest(){
	ph = 'c, e, g, c e g, co4, g, e, c'

	# Wait some time for step 3
	#print("Wait")
	#sleeptill(Now+10b)

	# Run test
	print("== Run basetest")
	realtime(ph,Now)

	# Do not quit too early.
	sleeptill(Now+2b+ph.length)

	# Mute output before quitting
	alloff()

	print("== Quit basetest")
	return(0)
}

# ----------------------------------------------

# A few volume changes.
#
function test_channel_volume_changes(){

	print("== Run test_channel_volume_changes")

	STEPS=30
	ph = 'go2c1'
	ph = 'c'
	ph.vol = 120;
	#ph.dur = 9b;
	short = 'f'
	short.vol = ph.vol

	print("1. Change channel volume. Both notes has same loudiness.")
	ph.type = NOTEON
	#realtime(ph,Now)
	for( i=0; i<STEPS; i++){
		vol = i*(100/STEPS) + 20
		realtime('c', Now)
		vc = chanvolchange(ph.chan,vol)
		printf("Set volume of channel %d to %d\n", ph.chan, vol)
		realtime(vc,Now)
		# Play new note. Above chan vol does affect it.
		realtime(short,Now)
		sleeptill(Now + (1b*10/STEPS) )
	}
	ph.type = NOTEOFF
	realtime(ph,Now)

	alloff()
	sleeptill(Now + 2b)

	print("2. Change expression volume. First note changes volume, but second not.")
	ph.type = NOTEON
	#realtime(ph,Now)
	for( i=0; i<STEPS; i++){
		vol = i*(100/STEPS) + 20
		realtime('c', Now)
		vc = chanexpressionchange(ph.chan,vol)
		printf("Set volume of expression %d to %d\n", ph.chan, vol)
		#realtime(vc,Now)
		# Play new note. Above expr. vol does not affect it, 
		# but already playing notes.
		realtime(short,Now)
		sleeptill(Now + (1b*10/STEPS) )
	}
	ph.type = NOTEOFF
	realtime(ph,Now)
	# Mute output before quitting
	alloff()
	print("== Quit test_channel_volume_changes")
	return(0)
}


# ----------------------------------------------

# Test support of polyphonic aftertouch messages
# by the synthesizer.
function test_pressure_support(ph){
	if( nargs() < 1) ph = 'c e g co4'

	print("== Run test_pressure_support")

	on = ph
	on.type = NOTEON
	off = ph
	off.type = NOTEOFF

	# Use modified util function with second arg 
	h = set_pressure(ph,120)

	# ... or use util function.
	l = on
	l.vol = 50
	l = pressure(l)

	# Playing
	print("Send NOTEON phrase")
	realtime(on, Now)
	sleeptill(Now+2b)

	print("Lower pressure")
	for( i=ph.vol; i>30; i-= 5){
		realtime( set_pressure(ph,i), Now)
		sleeptill(Now+1b)
		print(i)
	}
	print("Increase pressure")
	for( i=30; i<120; i+= 5){
		realtime( set_pressure(ph,i), Now)
		sleeptill(Now+1b)
		print(i)
	}

	print("Set high pressure instantly")
	realtime(h, Now)
	sleeptill(Now+2b)

	print("Send low pressure instantly")
	realtime(l, Now)
	sleeptill(Now+4b)

	print("Send NOTEOFF phrase")
	realtime(off, Now)
	sleeptill(Now+2b)

	# Mute output before quitting
	alloff()
	print("== Quit test_pressure_support")

	return(0)
}

# Creates polyphonic aftertouch message
# for (note.chan,note.pitch).
# Require support of the midicontroller. Not all
# can handle aftertouch messages!
function set_pressure(note,pressure){
	# This does not work:
	# ret = note
	# ret.type = PRESSURE
	# return(ret)

	ch = note.chan;
	p = note.pitch
	ret = ''
	for( n in note ){
		if( n.type == NOTE || n.type == NOTEON ){
			p = midibytes( 0xA0 | (n.chan-1), n.pitch, pressure )
			p.time = n.time
			ret += p
		}
	}
	#ret.length++

	return( ret )
}


# ----------------------------------------------

# Test functionality of area_phrases
function test_phrases_stage1(){
	print("== Run test_phrases")
	print("    One note fade in and")
	print("    one note fade out.")
	print("")
	print("Create area_phrases object")
	settings = settings_phrases()
	testarea = new area_phrases(settings)

	settings["phrases1"][0].chan = 1

	print("Test stage 1")
	steps = 40
	# First hand, increasing depth
	xs1 = 0.1
	ys1 = 0.1
	zs1 = settings["z_depth_limit1"] + 0.01
	zs1end = settings["z_depth_limit2"] - 0.01
	zs1d = (zs1end-zs1)/float(steps)

	# Second hand, lowering depth
	xs2 = 0.8
	ys2 = 0.8
	zs2 = settings["z_depth_limit2"] - 0.01
	zs2end = settings["z_depth_limit1"] + 0.01
	zs2d = (zs2-zs2end)/float(steps)

	testarea.update(1,1,[0=xs1,1=ys1,2=zs1])
	testarea.update(1,2,[0=xs2,1=ys2,2=zs2])
	for( i = 0; i < steps; i++){
		zs1 += zs1d
		zs2 -= zs2d
		sleeptill(Now+30)
		#print("Update stage 1")
		testarea.update(1,1,[0=xs1,1=ys1,2=zs1])
		testarea.update(1,2,[0=xs2,1=ys2,2=zs2])
	}

	sleeptill(Now+10b)

	print("Delete area_phrases object")
	deleteobject(testarea)
	alloff()
	print("== Quit test_phrases")
	return(0)
}

function test_phrases_stage2(){
	print("== Run test_phrases")
	print("    One hand moves around")
	print("    and a few notes should be heared.")
	print("")
	print("Create area_phrases object")
	settings = settings_phrases()
	testarea = new area_phrases(settings)

	z = settings["z_depth_limit1"] + 0.01
	# One stage 1 step
	testarea.update(1,1,[0=0.5,1=0.5,2=z])
	sleeptill(Now+30)

	print("Test stage 2")
	# Go into stage 2
	z = settings["z_depth_limit2"] + 0.01
	testarea.update(1,1,[0=0.9,1=0.9,2=z])

	# Move the hand
	x2 = 0.0
	for( i = 0; i< 20; i++){
		x2 += 0.05
		sleeptill(Now+20)
		testarea.update(1,1,[0=x2,1=x2,2=z])
	}
	for( i = 0; i< 20; i++){
		z += 0.01
		x2 -= 0.05
		sleeptill(Now+20)
		testarea.update(1,1,[0=x2,1=x2,2=z])
	}

	sleeptill(Now+500)

	print("Delete area_phrases object")
	deleteobject(testarea)
	alloff()
	print("== Quit test_phrases")
	return(0)
	# Hm, function doesn't return. Play task blockades even if kill(tid) stops it?!
}

# ----------------------------------------------

# Test functionality of area_knob and derivatives
function test_knobs(){
	print("== Run test_knobs")
	print("")

  VERBOSE=1
	print("Create area_knob object")
	testarea = new area_knob()
  deleteobject(testarea)

	print("Create area_channelswitcher object")
	settings = settings_channelswitcher()
	testarea = new area_channelswitcher(settings)

	print("Create and setup kinect, osc_looper and GridMusic_store objects")
  k = new kinect("", 0)
  k.get_areas()[0] = testarea
  k.start()

	print("Push five times right")
	steps = 10

  for( j = 0; j < steps; j++){
    print("Push ", j)
    xs1 = 0.9
    ys1 = 0.5
    zs1 = 0.0
    zs1end = 0.9
    zs1d = (zs1end-zs1)/float(steps)

    testarea.update(1,1,[0=xs1,1=ys1,2=zs1])
    for( i = 0; i < steps; i++){
      zs1 += zs1d
      sleeptill(Now+30)
      testarea.update(1,1,[0=xs1,1=ys1,2=zs1])
    }
    for( i = 0; i < steps; i++){
      zs1 -= zs1d
      sleeptill(Now+30)
      testarea.update(1,1,[0=xs1,1=ys1,2=zs1])
    }
  }

	sleeptill(Now+10b)
  
	print("Delete kinect object")
  deleteobject(k)

	print("Delete area_knob object")
	deleteobject(testarea)
	alloff()
	print("== Quit test_knobs")
	return(0)
}

# ----------------------------------------------
function GridMusic_test_help(){
	tests = [
	0 = ["name" = "basetest",
		"desc" = "Minimal test to check connection between keykit and midi synthesiszer."],
	1 = ["name" = "test_phrases_stage1",
		"desc" = "Test stage 1 of area_phrases"],
	2 = ["name" = "test_phrases_stage2",
		"desc" = "Test stage 2 of area_phrases"],
	3 = ["name" = "test_channel_volume_changes",
		"desc" = ""],
	4 = ["name" = "test_pressure_support",
		"desc" = "Send midi pressure messages. They are not supported by all synthesiszers."],
	5 = ["name" = "test_knobs",
		"desc" = "Test area_knob and area_channelswitcher class"]
	]
	
	print("== Available tests ==")
	for( t in tests ){
		print( tests[t]["name"], "\t", tests[t]["desc"])
	}
  eval(tests[0]["name"]+"()")
}

