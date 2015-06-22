function ktest1(){

	ph = 'cc4'
	ph.dur = 9b;
	ph.vol = 20;
	realtime(ph,Now)
	for( i=4; i<15; i++){
		if( i<10 ){
			ph.vol = 128-(10-i)*20
			vc = chanvolchange(ph.chan,ph.vol)
			realtime(vc,Now)
		}else{
			#	ph.vol = 120-(i-10)*20
			print("Mute")
			ph = ''
			ph.chan = 3
			ph.vol = 0 
			realtime(ph,Now)
		}
		print("play with vol ",ph.vol);
		sleeptill(Now+3b)
	}

}

# Creates polyphonic aftertouch message
# for (note.chan,note.pitch).
function set_pressure(note,pressure){
	#ret = note
	#ret.type = PRESSURE
	#return(ret)
	ch = note.chan;
	p = note.pitch

	# der midicontroller muss polyphonic aftertouch unterstuetzen, damit das etwas bewirkt!
	ret = ''
	#ret += midibytes( ch + 0x9f, p, pressure )
	ret += midibytes( 0xA0 | (ch-1), p, pressure )
	ret.length++

	return( ret )
}

function ktest2(ph){
	on = ph
	on.type = NOTEON
	off = ph
	off.type = NOTEOFF
	l = set_pressure(ph,40)
	h = set_pressure(ph,120)
	xx = ''
	X = 20
	F = 3 
	T = 5 
	x = ph
	x.vol = 0
	for(i=0; i<X;i++){
		x.time += T
		x.vol += F
		xx += x
	}
	for(i=0; i<X;i++){
		x.time += T;
		x.vol -= F
		xx += x
	}
	xxx = pressure(xx)
	ret = ["ph"=ph,"on"=on,"off"=off,"l"=l,"h"=h,"x"=xxx,"all"=on+x+off]
	return(ret)
}
