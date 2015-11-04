### React on velocity and maximal depth of hand
#
#

# Return struct which stores the settings for area_drum
function settings_piano{
	set = [
	# Notes for slices. Phrases or midi filenames.
	"phrases" = [0 = 'co2c10, co1c10'],

	# Unused variable for volume normalization of input files
	"volfactor" = 1.0
	]
	return(set)
}

class area_drum{
	method init(mfilenames, volfactor) {

		$.volfactor = 1.0
		if( nargs() > 1){
			$.volfactor = volfactor
		}

		$.mfilenames = []
		$.mfiles = []
		i = 0
		for( n in mfilenames ){
			$.mfilenames[i] = mfilenames[n];
			#$.mfiles[i] = normalize(readmf($.mfilenames[i]),-1,$.volfactor*GLOBALVOL)
			$.mfiles[i] = readmf($.mfilenames[i])
			i+=1
		}
		$.mfiles_size = sizeof($.mfilenames)	

		$.defaulthand = ["playing"=-1,"depth"=0,"strength"=0,"maxvelocity"=0,"maxdepth"=0,"timestamp"=0,"mindt"=1b,"mt"=-1,"state"=0]
		$.hands = []

		#first dim: -
		#second dim: -
		#third dim: detect velocity and depth
		$.inherit( new area(1,1,64) )

		$.update = $.update_handler
		$.play = $.play_handler

		#$.testfile = readmf("midi/olaf/FF7yuffi.mid")
		#$.testfile = readmf("midi/africa.mid")
		#$.testfile = readmf("midi/hb3.mid")
		$.testfile_note = 0

		#$.loopid = task $.playloop()
	}

	method update_handler(areaid, handid, xyz) {
		ix = floor( $.dim[0]*xyz[0])
		iy = floor( $.dim[1]*xyz[1])
		iz = floor( $.dim[2]*xyz[2])
		lock($)	
		#if( typeof( $.hands[handid] != "array" ) )
		#if( !(handid in $.hands) || Now - $.hands[handid]["timestamp"] > 100 )
		if( $.hands[handid] == "" || Now - $.hands[handid]["timestamp"] > 100 ){
			# add hand and exit
			$.hands[handid] = copy_array($.defaulthand);
			$.hands[handid]["maxdepth"] = z
			$.hands[handid]["depth"] = z
			$.hands[handid]["timestamp"] = Now
		}else if( Now - $.hands[handid]["timestamp"] > 2) {
			# update hand
			oldmaxvelocity =	$.hands[handid]["maxvelocity"]
			oldmaxdepth =	$.hands[handid]["maxdepth"]
			maxvelocity = (z - $.hands[handid]["depth"])/(Now - $.hands[handid]["timestamp"])
			if( oldmaxvelocity < maxvelocity ) $.hands[handid]["maxvelocity"] = maxvelocity

			$.hands[handid]["timestamp"] = Now
			$.hands[handid]["depth"] = z

			if( $.hands[handid]["state"] == 0){
				if( oldmaxdepth < z ){
					$.hands[handid]["maxdepth"] = z
				}else{
					$.hands[handid]["state"] = 1
					$.play_drum($.hands[handid],handid)
				}
			}else{
				if( z < oldmaxdepth-0.08 && $.hands[handid]["mindt"] < Now - $.hands[handid]["lastplay"] ){
					$.hands[handid]["maxdepth"] = z
					$.hands[handid]["maxvecocity"] = 0
					$.hands[handid]["state"] = 0 
				}
			}

		}
		unlock($)
	}

	method play_drum(hand,id){
		verbose("drum update", hand["maxvelocity"])

		volfactor = hand["maxvelocity"]*40;
		i = rand($.mfiles_size)
		hand["playing"] = i 
		drum = normalize($.mfiles[i], -1, volfactor*GLOBALVOL)

		drum =  major('fo2')

		#drum = $.testfile % $.testfile_note
		#print( $.testfile_note )
		#drum = ($.testfile) % ($.testfile_note)
		#drum.vol *= 1.5
		#$.testfile_note += 1;

		#drum.chan = 10+id
		drum.pitch += 2*id
		#drum = normalize(drum, -1, volfactor*GLOBALVOL)

		verbose("Play drum with volume",volfactor*GLOBALVOL )
		hand["lastplay"] = Now
		#kill(hand["mt"])
		hand["mt"] = realmidi(drum)
	}

	method play_handler() {
		verbose("play drum, not used")
		sleeptill(Now+1b)
	}

	method delete(){
		lock($)
		for( id in $.hands){
			#if($.hands[id] != "" ){
				verbose("Kill", $.hands[id]["mt"] )
				kill($.hands[id]["mt"])
				#}
			}
			unlock($)
		}
	}
