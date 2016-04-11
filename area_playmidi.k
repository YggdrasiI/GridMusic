# Play file from predefined list

function settings_playmidi{
	set = [
	# Directory of files (optional)
  # The keykit root directory will be used as anchor if empty.
	"directory" = "",

  # List of files
	"files" = [0="music/prelude.mid", 1="music/joy6.mid", 2="music/bachinv1.mid"],

  # Ignore horizontal hand position and select file randomly.
	"random" = 1,

  # Flag if volume of input phrases should be normalized
  # 0 - Skip normalization
  # 1 - Map volume linear into normalize_volume_range
  "normalize" = 1,

  # Map [minvol(ph), maxvol(ph)] on [min, max]
  "normalize_volume_range" = ["min"=0, "max"=100],

  # External function for transformation
  # Function arguments are phrase, min_vol and max_vol.
  "normalize_handler" = normalize, #nullfunc,

  # Limit channels of notes on first N. Notes with .chan > N will
  # mapped on previous (by %). Like normalization you could
  # change the used transformation function. 
  # 0 disables the channel limitiation.
  "max_nbr_of_chan" = 0,

  # Function arguments: phrase and max_nbr_of_chan.
  "reduce_handler" = reduce_channels,
   
  # Function arguments are phrase, min_vol and max_vol.

  # Split vertical selection into slices and set flag if phrases
  # should be repeated automatically.
  # Default setting play file one time in upper halve and repeats
  # in the lower halve.
  "repeat_slices" = [0=0, 1=1],

  # Flag if midi files should be loaded at initilization, but not first usage.
  "preload_files" = 1
	]

	base_set = settings_knob()
	extend_array(base_set, set)
	return(base_set)
}

class area_playmidi{

	method help(parent){
		print("area_playmidi help")
		print("")
    print("Play file from predefined list.")
    print("The first push starts the playing and the second push stops")
		print("The file will be repeated if the hand is in the lower halve of the area.")
		print("The horizontal position selects the file (if random flag not set).")
		print("")
		print("Implementation of area_knob class.")
		for( child in $.inherited() ){
			if( child.classof() == "area_knob" ){
				print( child.help($) )
			}
		}
	}

	method init(settings) {
		if( nargs() < 1 ){
			settings = settings_playmidi()
		}
		$.settings = settings

		$.settings["handler"]["push_on"] = $.push_on_handler
		$.settings["handler"]["push_off"] = $.push_off_handler

		if( $.settings["directory"] == "" ){
			$.settings["directory"] = chdir(".")
		}

		#load midi files
    $.mfiles = range(sizeof($.settings["files"]))
    if( $.settings["preload_files"] ){
      for( i in $.mfiles ){
        $.load_file(i)
      }
    }

		$.settings["dimX"] = sizeof($.mfiles)
		$.settings["dimY"] = sizeof($.settings["repeat_slices"])

    #$.hand_is_in = 0
		$.playing = -1
		$.mt = -1 # play task
		$.rt = -1 # repeat task
		$.xt = -1

		$.inherit( new area_knob($.settings) )

    #$.update = $.update_handler
    #$.play = $.play_handler
	}

  # If no filepath is given the value from $.settings will be used.
  method load_file(pos, filepath){
    if( nargs() < 2 ){
      filepath2 = $.settings["directory"] + "/" + $.settings["files"][pos]
    }else{
      filepath2 = filepath + "/" + $.settings["files"][pos]
		}
		verbose("(area_playmidi) Load", filepath2)
    ph = readmf(filepath2)

		if( $.settings["normalize"] ){
			vol_range = $.settings["normalize_volume_range"]
			ph = ($.settings["normalize_handler"])(ph, vol_range["min"], vol_range["max"])
		}

		rc = $.settings["reduce_channels"]
		if( rc > 0 ){
			ph = ($.settings["reduce_handler"])(ph, rc);
		}

		$.mfiles[pos] = ph
		#return(ph)
	}

	# Note that $ refers to area_knob object.
  method push_on_handler(areaid, handid, xyz){
    ixyz = $.get_ixyz(xyz)

    lock($$)
    if( $$.playing > -1 ){
      verbose("(area_playmidi) Warning, push_on send, but already playing. Missing push_off or second hand?!")
      #$.playing = -1
      #kill($$.rt)
      #kill($$.mt)
    }else{
			if( $$.settings["random"] ){
				$$.playing = rand(sizeof($$.mfiles))
			}else{
				$$.playing = ixyz[0]
			}
      verbose("(area_playmidi) start midi", $$, $)
      kill($$.rt)
      kill($$.mt)
      kill($$.xt)

      #set current midi file
      if( typeof($$.mfiles[$$.playing]) != "phrase" ){
        $$.load_file($$.playing)
      }
      $$.mfile = $$.mfiles[$$.playing]

      if( $.settings["repeat_slices"][ixyz[1]] > 0 ){
        $$.rt = task $$.repeat_current()
      }else{
        $$.xt = task $$.play_current($$.mfile.length)
      }

			verbose("Foo", typeof($$.mfile), $$.mfile.length)
			$$.mt =	realtime($$.mfile)
    }
    unlock($$)
    return(1)
  }

	method push_off_handler(areaid, handid, xyz){
		lock($)
		if( $$.playing > -1 ){
			verbose("(area_playmidi) stop midi")
			$$.playing = -1
			kill($$.rt)
			kill($$.mt)
		}else{
			verbose("(area_playmidi) Warning, push_off event send, but no midi file played.")
			verbose("(area_playmidi) This is no error if the midi already finished.")
			kill($$.rt)
			kill($$.mt)		# stop playing of previous one
			kill($$.xt)
		}
		unlock($)
		return(1)
	}

	method play_current(wait){
		sleeptill(Now + wait)
		#Kill should be redundant
		if( $.mt > -1 ){ kill($.mt) }

		# allow start of new file without stop push.
    #$.hand_is_in = 0
		$.playing = -1
	}

	method repeat_current(){
		d = $$.mfile.length
		sleeptill( Now + d )

		verbose("(area_playmidi) repeat midi")
		kill($$.mt)		# stop playing of previous one
		$$.mt = realtime($$.mfile)

		# Start new repeat task
		$$.rt = task $$.repeat_current()
	}


	method delete(){
			kill($$.rt)
			kill($$.mt)	
			kill($$.xt)
	}
}

