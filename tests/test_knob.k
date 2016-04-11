# Test functionality of area_knob and derivatives

function test_knobs(){
	print("== Run test_knobs")
	print("")

  VERBOSE=1
	print("Create area_knob object")
	testarea = new area_knob()
  deleteobject(testarea)

  #test_channelswitcher()
  #test_instrumentswitcher()
	test_playmidi()
}

function test_channelswitcher(){

	print("Create area_channelswitcher object")
	settings = settings_channelswitcher()
	settings["push_increments"] = [0=-1, 1=1]
	testarea = new area_channelswitcher(settings)

	print("Create and setup kinect, osc_looper and GridMusic_store objects")
  k = new kinect("", 0)
  k.get_areas()[0] = testarea
  k.start()

	print("Push five times: right, left, left, right, right")
	pushs = 5
	steps = 10
	xs = [0=0.9, 1=0.1, 2=0.1, 3=0.9, 4=0.9]
	ys = 0.5

	zs = 0.0
	zsend = 0.9
	zsd = (zsend-zs)/float(steps)

  for( j = 0; j < pushs; j++){
    print("Pushing loop ", j, "...")

    testarea.update(1,1,[0=xs[j],1=ys,2=zs])
    for( i = 0; i < steps; i++){
      zs += zsd
      sleeptill(Now+10)
      testarea.update(1,1,[0=xs[j],1=ys,2=zs])
    }
    for( i = 0; i < steps; i++){
      zs -= zsd
      sleeptill(Now+10)
      testarea.update(1,1,[0=xs[j],1=ys,2=zs])
    }
  }

	sleeptill(Now+3b)
  
	print("Delete kinect object")
  deleteobject(k)

	print("Delete area_channelswitcher object")
	deleteobject(testarea)
	alloff()
	print("== Quit test_channelswitcher")
	return(0)
}

function test_instrumentswitcher(){

	print("Create area_instrumentswitcher object")
	settings = settings_instrumentswitcher()
	settings["push_increments"] = [0=-1, 1=1]
	settings["instruments"] = [0=1, 1=10, 2=20, 3=30, 4=40 ]
	testarea = new area_instrumentswitcher(settings)

	print("Create and setup kinect, osc_looper and GridMusic_store objects")
  k = new kinect("", 0)
  k.get_areas()[0] = testarea
  k.start()

	print("Push five times right")
	pushs = 5
	steps = 10
	test_phrase = 'c,e,g,co4v127'
	xs = [0=0.9, 1=0.9, 2=0.9, 3=0.9, 4=0.9]
	ys = 0.5

	zs = 0.0
	zsend = 0.9
	zsd = (zsend-zs)/float(steps)

  for( j = 0; j < pushs; j++){
    print("Pushing loop ", j, "...")

    testarea.update(1,1,[0=xs[j],1=ys,2=zs])
    for( i = 0; i < steps; i++){
      zs += zsd
      sleeptill(Now+10)
      testarea.update(1,1,[0=xs[j],1=ys,2=zs])
    }
		#realtime(test_phrase, Now)
		#sleeptill(Now+2b)
    for( i = 0; i < steps; i++){
      zs -= zsd
      sleeptill(Now+10)
      testarea.update(1,1,[0=xs[j],1=ys,2=zs])
    }
  }

	sleeptill(Now+3b)
  
	print("Delete kinect object")
  deleteobject(k)

	print("Delete area_instrumentswitcher object")
	deleteobject(testarea)
	alloff()
	print("== Quit test_instrumentswitcher")
	return(0)
}

function test_playmidi(){

	print("Create area_playmidi object")
	settings = settings_playmidi()
	settings["random"] = 1
	settings["max_nbr_of_chan"] = 0
	settings["preload_files"] = 0
	settings["directory"] = "music/mi1"
	settings["files"] = [
	0="aufmi-dg.mid",
	1="aufmi-mt32.mid",
	2="fetbros-dg.mid",
	3="fetbros-mt32.mid",
	4="ghostdance-dg.mid",
	5="ghostdance-mt32.mid",
	6="lechuck.mid",
	7="love.mid",
	8="m1end-dg.mid",
	9="m1end-mt32.mid",
	10="m1theme-dg.mid",
	11="m1theme-mt32.mid",
	12="melee-dg.mid",
	13="melee-mt32.mid",
	14="scummbar-dg.mid",
	15="scummbar-mt32.mid",
	16="seamonkey-dg.mid",
	17="seamonkey-mt32.mid",
	18="stan.mid",
	19="voodoo-dg.mid",
	20="voodoo-mt32.mid"]
	testarea = new area_playmidi(settings)

	print("Current directory:", chdir())

	print("Create and setup kinect, osc_looper and GridMusic_store objects")
  k = new kinect("", 0)
  k.get_areas()[0] = testarea
  k.start()

	print("Push tree times: first file, stop, second file")
	pushs = 3
	steps = 10
	xs = [0=0.1, 1=0.5, 2=0.5]
	ys = 0.3

	zs = 0.0
	zsend = 0.9
	zsd = (zsend-zs)/float(steps)

  for( j = 0; j < pushs; j++){
    print("Pushing loop ", j, "...")

    testarea.update(1,1,[0=xs[j],1=ys,2=zs])
    for( i = 0; i < steps; i++){
      zs += zsd
      sleeptill(Now+10)
      testarea.update(1,1,[0=xs[j],1=ys,2=zs])
    }
    for( i = 0; i < steps; i++){
      zs -= zsd
      sleeptill(Now+10)
      testarea.update(1,1,[0=xs[j],1=ys,2=zs])
    }
	sleeptill(Now+30b)
  }

	sleeptill(Now+3b)
  
	print("Delete kinect object")
  deleteobject(k)

	print("Delete area_playmidi object")
	deleteobject(testarea)
	alloff()
	print("== Quit test_playmidi")
	return(0)
}
