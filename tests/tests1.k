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

function test_reflection(){

}
