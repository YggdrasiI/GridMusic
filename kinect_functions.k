###############################
## Capsuled print function.
## Strip on Release
###############################
function verbose(...){
	if(VERBOSE) print(...)
}

###############################
## Some util functions
###############################
function max(a, b){
	if(a<b) return(b)
	return(a)
}

function min(a, b){
	if(a>b) return(b)
	return(a)
}

function limit(min, val, max){
	if(val<min) return(min)
	if(val>max) return(max)
	return(val)
}

#########################
## Some phrases functions
#########################

# get length maximum for all notes
function phrase_length(ph){
	max = 0
	for( n in ph){
		#m = n.time + n.dur
		m = n.length
		if(m>max) max=m
	}
	return(max)
}

# Extract subphrase by time
function extract_beat(ph, beat, dur){
	begin = beat*dur
	end = begin+dur
	ret_ph = ph {??.time >= begin}
	ret_ph = ret_ph {??.time < end}
	ret_ph.time -= begin

	#print("Ab beat ", beat, ": ", ret_ph)
	#realtime(ret_ph)
	return(ret_ph)
}

function minor(k) { return(k|transpose(k, 3)|transpose(k, 7));}

function dur(basiston){
	abstaende = [0=0, 1=2, 2=4, 3=5, 4=7, 5=9, 6=11, 7=12]
	tonleiter = ''
	for( a in abstaende ){
		tonleiter += transpose(basiston, abstaende[a])
		#print( transpose(basiston, abstaende[a]))
	}
	return(tonleiter)
}

function durarr(basiston){
	abstaende = [0=0, 1=2, 2=4, 3=5, 4=7, 5=9, 6=11, 7=12]
	tonleiter = []
	for( a in abstaende ){
		tonleiter[a] = transpose(basiston, abstaende[a])
	}
	return(tonleiter)
}

# like aa - bb but ignore different vol
function filter_notes(aa, bb){
	cc = aa
	for( b in bb ){
		cc = cc { ??.pitch != b.pitch || ??.chan != b.chan }
	}
	return(cc)
}

## Redundant, use maxvolume in utils1.k
#function maxvol(ph){
#	max = 0
#	for(n in ph){
#		if( max<n.vol ) max = n.vol
#	}
#	return(max)
#}
#
## Redundant, use maxvolume in utils1.k
#function minvol(ph){
#	min = 128
#	for(n in ph){
#		if( min>n.vol ) min = n.vol
#	}
#	return(min)
#}

# shink or expand vol of ph to [minvol, maxvol]
function normalize(ph, ymin, ymax){
	xmax = maxvolume(ph)
	xmin = minvolume(ph)
	if( ymin == -1){ ymin=xmin; }
	if( xmax - xmin < 0.01 ){
		a = 0
		b = ymax
	}else{
		a = float(ymax-ymin)/(xmax-xmin)
		b = ymin-a*xmin
	}
	ph2 = ''
	for( n in ph ){
		if( n.type != MIDIBYTES ){
			n.vol = a*n.vol + b
		}
		ph2 |= n
	}
	return(ph2)
}

# Set volume of loudest note of phrase to 127 (or new_ph_vol)
# and scale other notes by the same factor.
# Useful to normalize input phrases.
function maximize_volume(ph, new_ph_vol){
	if( nargs() < 2 ){
		new_ph_vol = 127
	}
	ph_vol = maxvolume(ph)
	ph.vol *= float(new_ph_vol)/ph_vol
	return(ph)
}

# Extract part of phrase.
# There is already an other function
# in utils.k to do that.
# The obviously endtime is returned
# to get the same signature as extract2().
function extract1(ph, start_t, min_dt){
	begin = start_t
	end = begin+min_dt
	ret = []
	tmp_ph = ph {??.time >= begin}
	tmp_ph = tmp_ph {??.time < end}
	tmp_ph.time -= begin
	ret["ph"] = tmp_ph
	ret["t"] = start_t+min_dt
	return(ret)
}

# Extract part of phrase. If the duration
# of one extracted breaks min_dt, the
# second return argument differs from
# start_t + min_dt.
function extract2(ph, start_t, min_dt){
	begin = start_t
	end = begin+min_dt
	ret = []
	tmp_ph = ph {??.time >= begin}
	tmp_ph = tmp_ph {??.time < end}
	tmp_ph.time -= begin
	tmp_ph_c1 = tmp_ph { ??.chan == 1 }
	if( tmp_ph_c1.dur-1 > min_dt ){
		ret = extract2(ph, start_t, tmp_ph_c1.dur-1 )
	}else{
		ret["ph"] = tmp_ph
		ret["t"] = start_t+min_dt
	}

	return(ret)
}

# Reduce channels to nchan
function reduce_channels(ph, nchan){

	ph2 = ''
	for( p in ph ){
		if( p.chan > nchan ) p.chan=rand(nchan)
		ph2|=p
	}
	return(ph2)
}


#######################
## Some array functions
#######################

function copy_array(a){
	b = []
	for( n in a ){
		b[n] = a[n]
	}
	return(b)
}

# Normalize indizies
function copy_array2(a){
	b = []
	i = 0
	for( n in a ){
		b[i] = a[n]
		i+=1
	}
	return(b)
}

function transpose_arr(pharr, dpitch){
	ret = []
	for( n in pharr ){
		ret[n] = transpose(pharr[n], dpitch)
	}
	return(ret)
}
# extend (and overwrite) arr1 with arr2
function extend_array(arr1, arr2){
	for(i in arr2) arr1[i] = arr2[i]
}

# add all from arr2 to arr1 (and overwrite)
function join_arrays(arr1, arr2){
	ret = copy_array(arr1)
	extend_array(ret, arr2)
	return(ret)
}

# return index array of assoziative array
function index_array(arr1){
	i = 0
	ret = []
	for( v in arr1){
		ret[i] = v
		i++
	}
	return(ret)
}

# swap values of two arrays
function swap(arrA, indexA, arrB, indexB){
	tmp = arrA[indexA]
	arrA[indexA] = arrB[indexB]
	arrB[indexB] = tmp
}


###############################
## Some area related functions
###############################

# return 7 pads. 
# The indizes match to the frame with 7 big and 4 halve areas, thus 0, 3, 7 and 10 are skipped.
function pianoPads(){

	settings = settings_piano()
	settings["durations"] = [0=1b, 1=2b, 2=4b, 3=4b, 4=4b, 5=4b]
	settings["vol_range"] = ["low" = 60, "high" = 100]

	s2 = durarr('co2')
	s3 = durarr('c')
	s4 = durarr('co4')
	s5 = durarr('co5')

	# Same setting for each pad, but different notes
	settings["notes"] = [0=s3[0], 1=s4[0]]
	piano_c = new area_piano(settings)
	settings["notes"] = [1=s3[1], 1=s4[1]]
	piano_d = new area_piano(settings)
	settings["notes"] = [2=s3[2], 1=s4[2]]
	piano_e = new area_piano(settings)
	settings["notes"] = [3=s3[3], 1=s4[3]]
	piano_f = new area_piano(settings)
	settings["notes"] = [4=s2[4], 1=s3[4]]
	piano_g = new area_piano(settings)
	settings["notes"] = [5=s2[5], 1=s3[5]]
	piano_a = new area_piano(settings)
	settings["notes"] = [6=s2[6], 1=s3[6]]
	piano_b = new area_piano(settings)

	areas = [1=piano_c, 2=piano_f, 4=piano_d, 5=piano_g, 6=piano_b, 8=piano_e, 9=piano_a ]
	return(areas)
}


# delete objects of arr if they not related with
# obj
function deletesubitems(obj, arr){
	for( i in arr ){
		obj2 = arr[i]
		del = 1
		if( obj2 == obj){
			del=0
		}else{
			for( par in obj2.inherited() ){
				if (par==obj) del=0
			}
		}
		if( del ){
			delete(arr[i])
			verbose("Delete subitem")
			deleteobject(obj2)
		}
	}
}


###############################
## Midi message functions
###############################

# Convert note messages to pressure messages
# better&faster solution will be
# 'ph.type = PRESSURE' functionality, but this
# does not work for me.
function pressure(ph){
	ret = ''
	#Debug: Return empty phrase do omit error in zynaddsubfx
	#return(ret)
	for( n in ph ){
		if( n.type == NOTE || n.type == NOTEON ){
			p = midibytes( 0xA0 | (n.chan-1), n.pitch, n.vol )
			p.time = n.time
			ret += p
		}
	}
	return(ret)
}

# Return bytes to change instrument.
#
# To filter out messages which changes the instrument
# use ph = ph { ??.type != PROGRAM }
function change_instrument( channel, index ){
	statusbyte = 0xC0 + channel
	data1 = index & 0x7F
	ph = midibytes( statusbyte, data1 )
	return(ph)
}
