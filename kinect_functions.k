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
function max(a,b){
	if(a<b) return(b)
	return(a)
}

function min(a,b){
	if(a>b) return(b)
	return(a)
}

function limit(min,val,max){
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
function extract_beat(ph,beat,dur){
	begin = beat*dur
	end = begin+dur
	ret_ph = ph {??.time >= begin}
	ret_ph = ret_ph {??.time < end}
	ret_ph.time -= begin

	#print("Ab beat ",beat,": ",ret_ph)
	#realtime(ret_ph)
	return(ret_ph)
}

function minor(k) { return(k|transpose(k,3)|transpose(k,7));} 

function dur(basiston){
	abstaende = [0=0,1=2,2=4,3=5,4=7,5=9,6=11,7=12]
	tonleiter = ''
	for( a in abstaende ){
		tonleiter += transpose(basiston,abstaende[a]) 
		#print( transpose(basiston,abstaende[a]))
	}
	return(tonleiter)
}

function durarr(basiston){
	abstaende = [0=0,1=2,2=4,3=5,4=7,5=9,6=11,7=12]
	tonleiter = [] 
	for( a in abstaende ){
		tonleiter[a] = transpose(basiston,abstaende[a]) 
	}
	return(tonleiter)
}

# like aa - bb but ignore different vol
function filter_notes(aa,bb){
	cc = aa
	for( b in bb ){
		cc = cc { ??.pitch != b.pitch } 
	}
	return(cc)
}

function maxvol(ph){
	max = 0
	for(n in ph){
		if( max<n.vol ) max = n.vol	
	}
	return(max)
}
function minvol(ph){
	min = 128
	for(n in ph){
		if( min>n.vol ) min = n.vol	
	}
	return(min)
}

# shink or expand vol of ph to [minvol,maxvol]
function normalize(ph, ymin, ymax){
	xmax = maxvol(ph)
	xmin = minvol(ph)
	if( ymin == -1){ ymin=xmin; }
	if( xmax - xmin < 0.01 ){
		a = 0
		b = ymax
	}else{
		a = (ymax-ymin)/(xmax-xmin)
		b = ymin-a*xmin
	}
	ph2 = ''
	for( n in ph ){
		n.vol = a*n.vol + b 
		ph2 |= n
	}
	return(ph2)
}

# Extract part of phrase. 
# There is already an other function
# in utils.k to do that.
# The obviously endtime is returned
# to get the same signature as extract2().
function extract1(ph,start_t, min_dt){
	begin = start_t 
	end = begin+min_dt
	ret = []
	tmp_ph = ph {??.time >= begin}
	tmp_ph = tmp_ph {??.time < end}
	tmp_ph.time -= begin
	ret[0] = tmp_ph
	ret[1] = start_t+min_dt
	return(ret)
}

# Extract part of phrase. If the duration
# of one extracted breaks min_dt, the
# second return argument differ from
# start_t + min_dt.
function extract2(ph,start_t, min_dt){
	begin = start_t 
	end = begin+min_dt
	ret = []
	tmp_ph = ph {??.time >= begin}
	tmp_ph = tmp_ph {??.time < end}
	tmp_ph.time -= begin
	tmp_ph_c1 = tmp_ph { ??.chan == 1 }
	if( tmp_ph_c1.dur-1 > min_dt ){
		ret = extract2(ph,start_t, tmp_ph_c1.dur-1 )
	}else{
		ret[0] = tmp_ph
		ret[1] = start_t+min_dt
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
## Some array funcitons
#######################

function copy_array(a){
	b = []
	for( n in a ){
		b[n] = a[n]
	}
	return(b)
}

function copy_array2(a){
	b = []
	i = 0
	for( n in a ){
		b[i] = a[n]
		i+=1
	}
	return(b)
}

function transpose_arr(pharr,dpitch){
	ret = []
	for( n in pharr ){
		ret[n] = transpose(pharr[n],dpitch)
	}
	return(ret)
}
# extend (and overwrite) arr1 with arr2
function extend_array(arr1,arr2){
	for(i in arr2) arr1[i] = arr2[i]
}

# add all from arr2 to arr1 (and overwrite)
function join_arrays(arr1,arr2){
	ret = copy_array(arr1)
	extend_array(ret,arr2)
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
function swap(arrA,indexA,arrB,indexB){
	tmp = arrA[indexA]
	arrA[indexA] = arrB[indexB]
	arrB[indexB] = tmp
}


###############################
## Some area related functions
###############################

# return 7 pads. The indizes match to the frame with 7 big and 4 halve areas.
function pianoPads(){

	durations = [0=1b,1=2b,2=4b,3=4b,4=4b,5=4b]
	s2 = durarr('co2')
	s3 = durarr('c')
	s4 = durarr('co4')

	piano_c = new area_piano([0=s3[0],1=s4[0]],durations,50,128)
	piano_d = new area_piano([1=s3[1],1=s4[1]],durations,50,128)
	piano_e = new area_piano([2=s3[2],1=s4[2]],durations,50,128)
	piano_f = new area_piano([3=s3[3],1=s4[3]],durations,50,128)
	piano_g = new area_piano([4=s2[4],1=s3[4]],durations,50,128)
	piano_a = new area_piano([5=s2[5],1=s3[5]],durations,50,128)
	piano_b = new area_piano([6=s2[6],1=s3[6]],durations,50,128)

	areas = [1=piano_c, 2=piano_f, 4=piano_d, 5=piano_g, 6=piano_b, 8=piano_e, 9=piano_a ]
	return(areas)
}


# delete objects of arr if they not related with 
# obj
function deletesubitems(obj,arr){
	for( i in arr ){
		obj2 = arr[i]
		del = 1
		#check if obj related to arr[i]. 
		#			for( c in obj2.children() ){
		#				if (c==obj) del=0
		#			}
		if( obj2 == obj) del=0
		else{
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

# convert note messages to pressure messages
# better&faster solution will be
# 'ph.type = PRESSURE' functionality…
function pressure(ph){
	ret = ''
	for( n in ph ){
		if( n.type == NOTE || n.type == NOTEON ){
				p = midibytes( 0xA0 | (n.chan-1), n.pitch, n.vol )
				p.time = n.time
				ret += p
		}
	}
	return(ret)
}
