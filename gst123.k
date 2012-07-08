GST123HOST = "127.0.0.1" 
GST123PORT = 8877

OSCSTRUCT = [ "OSC_SET_VOLUME" = 1, "OSC_INCREASE_VOLUME" = 2, "OSC_DECREASE_VOLUME" = 3, "OSC_MUTE" = 4, "OSC_PAUSE" = 10, "OSC_PLAY" = 11, "OSC_FULLSCREEN" = 20, "OSC_RELATVE_SEEK" = 30, "OSC_SEEK" = 31, "OSC_PLAY_NEXT" = 32, "OSC_PLAY_PREVIOUS" = 33, "OSC_ADD_TRACK" = 40, "OSC_REMOVE_TRACK" = 41, "OSC_QUIT" = 99 ]

# Send osc messages to gst123 osc interface
# (one way communication)
class gst123{

method init(host, port){
	if( nargs() < 1 ){
		$.oscplayerhost = GST123HOST
	}else{
		$.oscplayerhost = host
	}
	if( nargs() < 2 ){
		$.oscplayerport = GST123PORT
	}else{
		$.oscplayerport = port
	}

	$.f = open(string($.oscplayerport)+"@"+$.oscplayerhost,"wb","osc_send")
}

# relative path should be select relative to the player.
method add_track(filepath, play, pos){

	if( nargs() > 0 ){
		if( nargs() < 2) m = [0="/gst123", 1=OSCSTRUCT["OSC_ADD_TRACK"], 2=filepath]
		else if( nargs() < 3) m = [0="/gst123", 1=OSCSTRUCT["OSC_ADD_TRACK"], 2=filepath, 3=play]
		else m = [0="/gst123", 1=OSCSTRUCT["OSC_ADD_TRACK"], 2=filepath, 3=play, 4=pos]

		$.playerosc(m)
	}
}

# relative path should be select relative to the player.
method remove_track(stopifplaying, pos){
	if( nargs() <  1 ) m = [0="/gst123", 1=OSCSTRUCT["OSC_REMOVE_TRACK"] ]
	else if( nargs() < 2 ) m = [0="/gst123", 1=OSCSTRUCT["OSC_REMOVE_TRACK"], 2=stopifplaying ]
	else m = [0="/gst123", 1=OSCSTRUCT["OSC_REMOVE_TRACK"], 2=stopifplaying, 3=pos ]
	$.playerosc(m)
}

method mute(mu){
	if( nargs() <  1 ) m = [0="/gst123", 1=OSCSTRUCT["OSC_MUTE"] ]
	else  m = [0="/gst123", 1=OSCSTRUCT["OSC_MUTE"], 2=mu ]
	$.playerosc(m)
}

method fullscreen(fs){
	if( nargs() <  1 ) m = [0="/gst123", 1=OSCSTRUCT["OSC_FULLSCREEN"] ]
	else  m = [0="/gst123", 1=OSCSTRUCT["OSC_FULLSCREEN"], 2=fs ]
	$.playerosc(m)
}

method seek(sec){
	if( nargs() <  1 ) m = [0="/gst123", 1=OSCSTRUCT["OSC_SEEK"] ]
	else  m = [0="/gst123", 1=OSCSTRUCT["OSC_SEEK"], 2=sec ]
	$.playerosc(m)
}

method relative_seek(sec){
	if( nargs() <  1 ) m = [0="/gst123", 1=OSCSTRUCT["OSC_RELATVE_SEEK"] ]
	else  m = [0="/gst123", 1=OSCSTRUCT["OSC_RELATVE_SEEK"], 2=sec ]
	$.playerosc(m)
}

# map 0,...,128 to [0,1]
method setVol(volume_){
	print("Gst123: setVol called ", volume_)
	volumeScaled = volume_/128.0
	m = [0="/gst123", 1=OSCSTRUCT["OSC_SET_VOLUME"], 2=volumeScaled]
	$.playerosc(m)
}

method incVol(){
	m = [0="/gst123", 1=OSCSTRUCT["OSC_INCREASE_VOLUME"]]
	$.playerosc(m)
}

method decVol(){
	m = [0="/gst123", 1=OSCSTRUCT["OSC_DECREASE_VOLUME"]]
	$.playerosc(m)
}

# send osc command to toggle pause
method pause(p){
	if( nargs() < 1 ) p=1
	m = [0="/gst123", 1=OSCSTRUCT["OSC_PAUSE"], 2=p]
	$.playerosc(m)
}

method play(tracknr){
	m = [0="/gst123", 1=OSCSTRUCT["OSC_PLAY"], 2=tracknr]
	$.playerosc(m)
}

method next(){
	m = [0="/gst123", 1=OSCSTRUCT["OSC_PLAY_NEXT"]]
	$.playerosc(m)
}

method previous(){
	m = [0="/gst123", 1=OSCSTRUCT["OSC_PLAY_PREVIOUS"]]
	$.playerosc(m)
}

method stop(){
	m = [0="/stop"]
	$.playerosc(m)
}

# quit player
method quit(){
	m = [0="/gst123", 1=OSCSTRUCT["OSC_QUIT"]]
	$.playerosc(m)
}

method playerosc(m) {
	#print("Sending OSC m=",m)
	mdep("osc","send",$.f,m)
}

method delete(){
	close($.f)
}

method test(){
	file = "/home/olaf/Musik/Ghost in the Shell Stand Alone Complex O.S.T. 3/07 - Europe.mp3"
	$.add_track(file, 1, 3);
	$.setVol(128);

}

}
