
# setting with one square.
function setting0(loop){

	possible_notes = [0='c',1='d',2='e',3='f',4='g',5='a',6='b',7='co4']
	speeds = [0=2b,1=1b,2=48,3=24,4=12]
	durations = [0=1b,1=4b,2=8b,3=16b,4=32b,5=32b]

	possible_notes2 = []
	for( i in possible_notes ){
		n = possible_notes[i]
		n.chan = 2
		possible_notes2[i] = n
	}

	kstore = []
	piano = new area_piano(possible_notes,durations,30,128)
	piano2 = new area_piano(possible_notes2,durations,30,128)

	areas = [0=piano,1=piano2]

	if(nargs() < 1 || loop != 0){
		looper(areas, kstore)
	}
	return(areas)
}

# setting with four big squares and sliders for volume and bpm.
function setting1(loop){

	possible_notes = [0='c',1='d',2='e',3='f',4='g',5='a',6='b',7='co4']
	possible_notes2 = transpose_arr(possible_notes,-8)
	speeds = [0=2b,1=1b,2=48,3=24,4=12]
	durations = [0=1b,1=4b,2=8b,3=16b,4=32b,5=32b]

	files = []
	files["1"] = "prelude.mid"
	files["2"] = "jsbach.mid"
	files["3"] = "bachinv1.mid"
	files["4"] = "bachinv2.mid"
	files["5"] = "bachinv3.mid"

	files2 = []
	files2["1"] = "patt0.mid" 
	files2["2"] = "patt1.mid" 
	files2["3"] = "patt2.mid" 
	files2["4"] = "patt3.mid"
	files2["5"] = "patt4.mid"
	files2["6"] = "patt5.mid"

	files3 = []
	files3[0] = "midi/olaf/lain_duvet.mid"
	files3[1] = "midi/olaf/bwv852.mid"
	files3[2] = "midi/olaf/chop32n2.mid"
	files3[3] = "midi/olaf/chop64v1.mid"
	files3[4] = "midi/olaf/FF7yuffi.mid"

	piano = new area_piano(possible_notes,durations,30,128)
	playmidi = new area_playmidi(files3, 0.9)
	drums = drums()
	bpm_area = new area_bpm( 30, 190, 20, 1)
	volume_area = new area_volume( 20, 127, 5)
	#	mp3 = mp3list1(volume_area)

	kstore = []
	#	switcher = new area_setting_switcher(kstore,SETTINGS)


	areas = [0=volume_area, 1=drums, 2=drums, 3=piano, 4=piano, 5=piano, 6=piano, 7=bpm_area, 8=playmidi, 9=playmidi, 10=volume_area]

	if(nargs() < 1 || loop != 0){
		looper(areas, kstore)
	}
	return(areas)
}

function setting2(loop){

	possible_notes = [0='c',1='d',2='e',3='f',4='g',5='a',6='b',7='co4']
	speeds = [0=2b,1=1b,2=48,3=24,4=12]
	durations = [0=1b,1=4b,2=8b,3=16b,4=32b,5=32b]

	files3 = []
	files3[0] = "midi/olaf/FF7yuffi.mid"

	drum1 = []
	drum1[0] = "drums/Latin6.mid"
	#drum1[0] = "midi/olaf/FF7yuffi.mid"

	d1 = new area_drum(drum1,1)
	d2 = new area_drum(drum1,1)
	d4 = new area_drum(drum1,1)
	d5 = new area_drum(drum1,1)
	d6 = new area_drum(drum1,1)
	d8 = new area_drum(drum1,1)
	d9 = new area_drum(drum1,1)
	playmidi = new area_playmidi(files3, 0.9)
	drums = drums()
	bpm_area = new area_bpm( 30, 190, 20, 1)
	volume_area = new area_volume( 20, 127, 5)

	kstore = []
	switcher = new area_setting_switcher(kstore,SETTINGS)

	areas = [0=volume_area, 1=d1, 2=d2, 3=volume_area, 4=d4, 5=d5, 6=d6, 7=bpm_area, 8=d8, 9=d9, 10=switcher]

	if(nargs() < 1 || loop != 0){
		looper(areas, kstore)
	}
	return(areas)
}

function setting3(loop){

	possible_notes = [0='c',1='d',2='e',3='f',4='g',5='a',6='b',7='co4']
	possible_notes2 = [0='c',1='d',2='e',3='f']
	speeds = [0=2b,1=1b,2=48,3=24,4=12]
	#durations = [0=24,1=1b,2=2b,3=4b,4=8b,5=16b]
	durations = [0=1b,1=4b,2=8b,3=16b,4=32b,5=32b]

	files3 = []
	files3[0] = "midi/Suserl.mid"
	files3[1] = "midi/Teufelsteinpolka.mid"
	files3[2] = "midi/sLieserl.mid"
	files3[3] = "midi/hb3.mid"

	#piano = new area_piano(possible_notes,durations,30,128)

	data = stepfile_data(files3[rand(sizeof(files3)+1)])
	stepfile1 = new area_stepfile(possible_notes2,durations,30,128, data)
	drumA = []
	drumA[0] = "testdrum.mid"
	drumB = []
	drumB[0] = "testdrum.mid"

	#dA = new area_drum(drumA,1)
	#dB = new area_drum(drumB,1)
	#playmidi = new area_playmidi(files3, 0.9)

	bpm_area = new area_bpm( 30, 190, 20, 1)
	volume_area = new area_volume( 20, 127, 5)
	mp3 = mp3list1(volume_area)

	kstore = []
	switcher = new area_setting_switcher(kstore,SETTINGS)

	areas = [0=volume_area, 1=stepfile1, 2=stepfile1, 3=switcher, 4=stepfile1, 5=stepfile1, 6=stepfile1, 7=bpm_area, 8=stepfile1, 9=stepfile1, 10=mp3]

	if(nargs() < 1 || loop != 0){
		looper(areas, kstore)
	}
	return(areas)
}

# C-Major pads
#
#  0,vol          7,bpm
#         4,d'       
#   1,c'          8,e'
#         5,g,g'   
#   2,f'          9,a
#         6,b
#  3,vol          10,free
#
function setting4(loop){

	possible_notes = [0='c',1='d',2='e',3='f',4='g',5='a',6='b',7='co4']
	possible_notes2 = [0='c',1='d',2='e',3='f']
	speeds = [0=2b,1=1b,2=48,3=24,4=12]
	#durations = [0=24,1=1b,2=2b,3=4b,4=8b,5=16b]
	durations = [0=1b,1=4b,2=8b,3=16b,4=32b,5=32b]

	piano_c = new area_piano([0='co4',1='co4'],durations,30,128)
	piano_d = new area_piano([0='do4',1='do4'],durations,30,128)
	piano_e = new area_piano([0='eo4',1='eo4'],durations,30,128)
	piano_f = new area_piano([0='fo4',1='fo4'],durations,30,128)
	piano_g = new area_piano([0='g',1='g',2='go4'],durations,30,128)
	piano_a = new area_piano([0='a'],durations,30,128)
	piano_b = new area_piano([0='b'],durations,30,128)

	files = []
	files[0] = "midi/christian/B70-.mid"
	files[1] = "midi/christian/B70.mid"
	files[2] = "midi/christian/B80.mid"
	#	playmidi = new area_playmidi(files, 1.5)

	#bpm_area = new area_bpm( 30, 190, 20, 1)
	volume_area = new area_volume( 20, 127, 5)

	kstore = []
	#switcher = new area_setting_switcher(kstore,SETTINGS)

	#areas = [0=volume_area, 1=piano_c, 2=piano_f, 3=switcher, 4=piano_d, 5=piano_g, 6=piano_b, 7=bpm_area, 8=piano_e, 9=piano_a , 10=playmidi]
	#areas = [0=volume_area, 1=piano_c, 2=piano_f, 3=volume_area, 4=piano_d, 5=piano_g, 6=piano_b, 7=bpm_area, 8=piano_e, 9=piano_a ]
	areas = [0=volume_area, 1=piano_c, 2=piano_f, 3=volume_area,  4=piano_d, 5=piano_g, 6=piano_b, 7=volume_area, 8=piano_e, 9=piano_a, 10=volume_area ]

	if(nargs() < 1 || loop != 0){
		looper(areas, kstore)
	}
	return(areas)
}

function setting5(loop){

	pn1 = [0='c',1='d',2='e',3='f']
	pn2 = [0='c',1='d',2='e',3='f']
	durations = [0=1b,1=4b,2=8b,3=16b,4=32b,5=32b]

	#piano = new area_piano(possible_notes,durations,30,128)

	data = stepfile_data("midi/hb3.mid")

	stepfile_c = new area_stepfile(pn1,durations,30,128, data, [0='co4'])
	stepfile_d = new area_stepfile(pn1,durations,30,128, data, [0='do4'])
	stepfile_e = new area_stepfile(pn1,durations,30,128, data, [0='eo4'])
	stepfile_f = new area_stepfile(pn1,durations,30,128, data, [0='fo4'])
	stepfile_g = new area_stepfile(pn1,durations,30,128, data, [0='g', 1='g', 2='go4', 3='go4'])
	stepfile_a = new area_stepfile(pn1,durations,30,128, data, [0='a'])
	stepfile_b = new area_stepfile(pn1,durations,30,128, data, [0='b'])

	bpm_area = new area_bpm( 30, 190, 20, 1)
	volume_area = new area_volume( 20, 127, 5)
	mp3 = mp3list1(volume_area)

	kstore = []
	switcher = new area_setting_switcher(kstore,SETTINGS)

	areas = [0=volume_area, 1=stepfile_c, 2=stepfile_f, 3=switcher, 4=stepfile_d, 5=stepfile_g, 6=stepfile_b, 7=bpm_area, 8=stepfile_e, 9=stepfile_a, 10=mp3]

	if(nargs() < 1 || loop != 0){
		looper(areas, kstore)
	}
	return(areas)
}


function xxx(ph,tone){
	ph2 = ph
	ph2.pitch = tone.pitch
	return(ph2)
}


# Like setting4, but with  instrument phrases.
function setting6(loop,nr){
	if( nargs() < 2) nr = 1 

	possible_notes = [0='c',1='d',2='e',3='f',4='g',5='a',6='b',7='co4']
	possible_notes2 = [0='c',1='d',2='e',3='f']
	speeds = [0=2b,1=1b,2=48,3=24,4=12]
	#durations = [0=24,1=1b,2=2b,3=4b,4=8b,5=16b]
	durations = [0=1b,1=4b,2=8b,3=16b,4=32b,5=32b]

	filename = sprintf("midi/christian/Drums/%i.mid",nr);
	inst = readmf(filename);
	foo = []
	for(i=0;i<30;i++){
		foo[i] = inst
		foo[i].pitch = inst.pitch+i
	}

	piano_c = new area_piano([0=xxx(inst,'co4'),1=xxx(inst,'co4')],durations,90,128)
	piano_d = new area_piano([0=xxx(inst,'do4'),1=xxx(inst,'do4')],durations,90,128)
	piano_e = new area_piano([0=xxx(inst,'eo4'),1=xxx(inst,'eo4')],durations,90,128)
	piano_f = new area_piano([0=xxx(inst,'fo4'),1=xxx(inst,'fo4')],durations,90,128)
	piano_g = new area_piano([0=xxx(inst,'go3'),1=xxx(inst,'go3'),2=xxx(inst,'go4')],durations,90,128)
	#piano_g = new area_piano(foo,durations,90,128)
	piano_a = new area_piano([0=xxx(inst,'ao3'),1=xxx(inst,'ao3')],durations,90,128)
	piano_b = new area_piano([0=xxx(inst,'bo3'),1=xxx(inst,'bo3')],durations,90,128)

	files = []
	files[0] = "midi/hb3.mid"
	files[1] = "midi/christian/HB1.mid"
	playmidi = new area_playmidi(files, 0.8)

	bpm_area = new area_bpm( 30, 190, 20, 1)
	volume_area = new area_volume( 20, 127, 5)

	kstore = []
	switcher = new area_setting_switcher(kstore,SETTINGS)

	areas = [0=volume_area, 1=piano_c, 2=piano_f, 3=switcher, 4=piano_d, 5=piano_g, 6=piano_b, 7=bpm_area, 8=piano_e, 9=piano_a, 10=playmidi]

	if(nargs() < 1 || loop != 0){
		looper(areas, kstore)
	}
	return(areas)
}


# Play different mp3's.
function settingGst2(loop){

	files=[ 1="/home/olaf//Musik/Ghost in the Shell Stand Alone Complex O.S.T. 3/01 - the end of all you'll know.mp3",
	2="/home/olaf//Musik/Ghost in the Shell Stand Alone Complex O.S.T. 3/02 - Torukia.mp3",
	3="/home/olaf//Musik/Ghost in the Shell Stand Alone Complex O.S.T. 3/03 - know your enemy.mp3",
	4="/home/olaf//Musik/Ghost in the Shell Stand Alone Complex O.S.T. 3/04 - Laser Seeker.mp3",
	5="/home/olaf//Musik/Ghost in the Shell Stand Alone Complex O.S.T. 3/05 - break through.mp3",
	6="/home/olaf//Musik/Ghost in the Shell Stand Alone Complex O.S.T. 3/06 - flying low.mp3",
	7="/home/olaf//Musik/Ghost in the Shell Stand Alone Complex O.S.T. 3/07 - Europe.mp3",
	8="/home/olaf//Musik/Ghost in the Shell Stand Alone Complex O.S.T. 3/08 - Hantou no Higashi.mp3",
	9="/home/olaf//Musik/Ghost in the Shell Stand Alone Complex O.S.T. 3/09 - Mikansei Love Story.mp3",
	10="/home/olaf//Musik/Ghost in the Shell Stand Alone Complex O.S.T. 3/10 - Christmas in the Silent Forest.mp3",
	11="/home/olaf//Musik/Ghost in the Shell Stand Alone Complex O.S.T. 3/11 - access all areas.mp3",
	12="/home/olaf//Musik/Ghost in the Shell Stand Alone Complex O.S.T. 3/12 - sacred terrorist.mp3",
	13="/home/olaf//Musik/Ghost in the Shell Stand Alone Complex O.S.T. 3/13 - dear john.mp3",
	14="/home/olaf//Musik/Ghost in the Shell Stand Alone Complex O.S.T. 3/14 - 35.7c.mp3",
	15="/home/olaf//Musik/Ghost in the Shell Stand Alone Complex O.S.T. 3/15 - Smile.mp3",
	16="/home/olaf//Musik/Ghost in the Shell Stand Alone Complex O.S.T. 3/16 - flashback memory stick.mp3",
	17="/home/olaf//Musik/Ghost in the Shell Stand Alone Complex O.S.T. 3/17 - dew.mp3"
	];

	bpm_area = new area_bpm( 30, 190, 20, 1)
	volume_area = new area_volume( 20, 127, 5)

	mp3_1 = new area_gst123([0=files[7],1=files[8]],volume_area )
	mp3_2 = new area_gst123([0=files[1],1=files[11],2=files[12],3=files[13]])
	mp3_4 = new area_gst123([0=files[2],1=files[14],2=files[15],3=files[16]])
	mp3_5 = new area_gst123([0=files[3],1=files[17]])
	mp3_6 = new area_gst123([0=files[4],1=files[5]])
	mp3_8 = new area_gst123([0=files[9],1=files[10]])
	mp3_9 = new area_gst123([0=files[6],1=files[6]])


	files3 = []
	files3[0] = "midi/olaf/FF7yuffi.mid"
	files3[1] = "midi/olaf/nausicaa1.mid"
	files3[2] = "midi/africa.mid"
	files3[3] = "midi/africa.mid"
	playmidi = new area_playmidi(files3, 1.0)

	kstore = []
	switcher = new area_setting_switcher(kstore,SETTINGS)

	areas = [0=volume_area, 1=mp3_1, 2=mp3_2, 3=switcher, 4=mp3_4, 5=mp3_5, 6=mp3_6, 7=bpm_area, 8=mp3_8, 9=mp3_9, 10=playmidi]

	if(nargs() < 1 || loop != 0){
		looper(areas, kstore)
	}
	return(areas)
}

# zynaddsubfx setting: KinectSet1.xmz 
function kinectSet1(loop){

	durations = [0=1b,1=4b,2=8b,3=8b,4=8b,5=8b]
	durationsLong = [1=4b,2=8b,3=8b,4=16b,5=16b]
	#3,2,2,3,2
	newage1 = [0='co4', 1='e-o4', 2='fo4', 3='go4', 4='b-o4']
	newage1Major = [0=major('c'), 1=major('e-'), 2=major('f'), 3=major('g'), 4=major('b-')]
	newage2 = [0='e-', 1='f+', 2='g+', 3='a+', 4='c']

	#hammond = [0=minor('e-c6'), 1=minor('f+c6'), 2=minor('g+c6'), 3=minor('a+c6'), 4=minor('cc6')]
	hammond = [0='e-c6', 1='f+c6', 2='g+c6', 3='a+c6', 4='cc6']
	impDream5 = [0='co4,fo3t96', 1='e-o4,go3t96', 2='fo4,b-o3t96', 3='go4,co4t96', 4='b-o4,e-o4t96']
	resonance = [0='cc3o2', 1='e-c3o2', 2='fc3o3', 3='gc3o3', 4='b-c3o4']
	metal = [ 0='cd192c4', 1='dd192c4', 2='ed192c4', 3='fd192c4', 4='gd192c4', 5='ad192c4', 6='bd192c4', 7='co4d192c4' ]
	bubble = [ 0='cc8', 1='dc8', 2='ec8', 3='fc8', 4='gc8', 5='ac8', 6='bc8', 7='co4c8', 8='do4c8', 9='eo4c8', 10='fo4c8', 11='go4c8', 12='ao4c8', 13='bo4c8', 14='co5c8' ]
	arpeggio3 = [0=minor('e-'), 1=minor('f+'), 2=minor('g+'), 3=minor('a+'), 4=minor('c')]
	softvibes = [0='e-c7', 1='f+c7', 2='g+c7', 3='a+c7', 4='cc7']
	piano = [0='e-c9', 1='f+c9', 2='g+c9', 3='a+c9', 4='cc9']

	#piano_g = new area_piano([4=s2[4],1=s3[4],2=s4[4]],durations,50,128)
	piano1 = new area_piano(impDream5,durations,30,90)
	piano2 = new area_piano(bubble,durations,50,128)
	piano4 = new area_piano(hammond,durationsLong,20,100)
	piano5 = new area_piano(piano,durations,50,128)
	piano8 = new area_piano(arpeggio3,durations,50,100)
	piano9 = new area_piano(metal,durations,50,100)

	trumpet = new area_trumpet(resonance,20,121)

	#bpm_area = new area_bpm( 30, 190, 20, 1)
	volume_area = new area_volume( 20, 127, 5)

	kstore = []
	switcher = new area_setting_switcher(kstore,SETTINGS)

	channels = [0=1,1=2,2=3]
	channel_area = new area_channelswitcher(channels,kstore);

	#multi_area = new area_multimode(kstore)

	areas = [0=volume_area, 1=piano1, 2=piano2, 3=switcher,  4=piano4, 5=piano5 , 6=trumpet, 7=channel_area, 8=piano8, 9=piano9, 10=volume_area ]

	if(nargs() < 1 || loop != 0){
		looper(areas, kstore)
	}
	return(areas)
}

# zynaddsubfx setting: KinectSet2.xmz 
function kinectSet2(loop){

	durations = [0=1b,1=4b,2=8b,3=8b,4=8b,5=8b]
	durationsLong = [1=4b,2=8b,3=8b,4=16b,5=16b]
	#3,2,2,3,2
	newage1 = [0='co4', 1='e-o4', 2='fo4', 3='go4', 4='b-o4']
	newage1Major = [0=major('c'), 1=major('e-'), 2=major('f'), 3=major('g'), 4=major('b-')]
	newage2 = [0='e-', 1='f+', 2='g+', 3='a+', 4='c']

	#hammond = [0=minor('e-c6'), 1=minor('f+c6'), 2=minor('g+c6'), 3=minor('a+c6'), 4=minor('cc6')]
	#softvibes = [0='e-c7', 1='f+c7', 2='g+c7', 3='a+c7', 4='cc7']

	impDream5 = [0='co4,fo3t96', 1='e-o4,go3t96', 2='fo4,b-o3t96', 3='go4,co4t96', 4='b-o4,e-o4t96']
	bubble = [ 0='cc2', 1='dc2', 2='ec2', 3='fc2', 4='gc2', 5='ac2', 6='bc2', 7='co4c2', 8='do4c2', 9='eo4c2', 10='fo4c2', 11='go4c2', 12='ao4c2', 13='bo4c2', 14='co5c2' ]
	hammond = [0='e-c3', 1='f+c3', 2='g+c3', 3='a+c3', 4='cc3']
	piano = [0='e-c4', 1='f+c4', 2='g+c4', 3='a+c4', 4='cc4']
	arpeggio3 = [0=minor('e-c5'), 1=minor('f+c5'), 2=minor('g+c5'), 3=minor('a+c5'), 4=minor('co4c5')]
	metal = [ 0='cd192c6', 1='dd192c6', 2='ed192c6', 3='fd192c6', 4='gd192c6', 5='ad192c6', 6='bd192c6', 7='co4d192c6' ]
	resonance = [0='cc7o2', 1='e-c7o2', 2='fc7o3', 3='gc7o3', 4='b-c7o4']

	piano1 = new area_trumpet(impDream5,20,121)
	piano2 = new area_trumpet(bubble,20,121)
	piano4 = new area_trumpet(hammond,20,121)
	piano5 = new area_trumpet(piano,20,121)
	piano8 = new area_trumpet(arpeggio3,20,121)
	piano9 = new area_trumpet(metal,20,121)

	trumpet = new area_trumpet(resonance,20,121)

	#bpm_area = new area_bpm( 30, 190, 20, 1)
	volume_area = new area_volume( 20, 127, 5)

	kstore = []
	switcher = new area_setting_switcher(kstore,SETTINGS)

	channels = [0=1,1=2,2=3]
	channel_area = new area_channelswitcher(channels,kstore);

	#multi_area = new area_multimode(kstore)

	areas = [0=volume_area, 1=piano1, 2=piano2, 3=switcher,  4=piano4, 5=piano5 , 6=trumpet, 7=channel_area, 8=piano8, 9=piano9, 10=volume_area ]

	if(nargs() < 1 || loop != 0){
		looper(areas, kstore)
	}
	return(areas)
}



# Halloween, Play different mp3's on two panels
function settingHalloween(loop){

	speeds = [0=2b,1=1b,2=48,3=24,4=12]
	durations = [0=1b,1=4b,2=8b,3=16b,4=32b,5=32b]
	durations2 = [0=1b,1=2b,2=2b,3=2b,4=2b,5=2b]

	possible_notes0 = [0='c',1='d',2='e',3='f',4='g',5='a',6='b',7='co4']

	possible_notes1 = []
	for( i in possible_notes0 ){
		n = possible_notes0[i]
		n.chan = 2
		possible_notes1[i] = n
	}
	possible_notes2 = []
	for( i in possible_notes0 ){
		n = possible_notes0[i]
		n.chan = 3
		possible_notes2[i] = n
	}
	possible_notes3 = []
	for( i in possible_notes0 ){
		n = possible_notes0[i]
		n.chan = 4
		possible_notes3[i] = n
	}

	possible_notes_multichannel = [ 0='c',1='e',2='g',3='a',4='co4', 5='cc2',6='ec2',7='gc2',8='ac2',9='co4', 10='cc3',11='ec3',12='gc3',13='ac3',14='co4', 14='cc4',15='ec4',16='gc4',17='ac4',18='co4' ]

	piano_0 = new area_piano(possible_notes0,durations2,30,128)
	piano_1 = new area_piano(possible_notes1,durations2,30,128)
	piano_2 = new area_piano(possible_notes2,durations2,30,128)
	piano_3 = new area_piano(possible_notes3,durations2,30,128)
	#mp3_0 = new area_systemcalls()
	#mp3_1 = new area_systemcalls()

	kstore = []
	areas = [ 0=piano_0, 1=piano_1, 2=piano_2, 3=piano_3 ]

	if(nargs() < 1 || loop != 0){
		looper(areas, kstore)
	}
	return(areas)
}

# Ein Pianofeld und ein Trompetenfeld zum Testen
# beider Klassen.
function settingH2(loop){

	speeds = [0=2b,1=1b,2=48,3=24,4=12]
	durations = [0=1b,1=4b,2=8b,3=16b,4=32b,5=32b]
	durations2 = [0=1b,1=2b,2=2b,3=2b,4=2b,5=2b]

	possible_notes0 = [0='c',1='d',2='e',3='f',4='g',5='a',6='b',7='co4']
	piano_0 = new area_piano(possible_notes0,durations2,30,128)

	# Jeweils zwei Noten, etwas zeitversetzt
	#impDream5 = [0='co4,fo3t96', 1='e-o4,go3t96', 2='fo4,b-o3t96', 3='go4,co4t96', 4='b-o4,e-o4t96']
	#piano_1 = new area_trumpet(impDream5,10,101)

	# Test of playmidi class
	#drums = drums()

	# Test of stepfile class
	files = []
	files[0] = "music/midi/africa.mid"
	files[1] = "music/midi/olaf/monkazimo.mid"
	files[2] = "music/midi/hb3.mid"
	#data = stepfile_data(files[rand(sizeof(files))])
	data = stepfile_data(files[1])
	stepfile1 = new area_stepfile(possible_notes0,durations2,30,128, data)

	kstore = []
	#areas = [ 0=piano_0, 1=piano_1 ]
	areas = [ 0=piano_0, 1=stepfile1 ]

	if(nargs() < 1 || loop != 0){
		looper(areas, kstore)
	}
	return(areas)
}
