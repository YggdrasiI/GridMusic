# Test functionality of area_knob and derivatives

function test_knobs(){
	print("== Run test_knobs")
	print("")

  VERBOSE=1
	print("Create area_knob object")
	testarea = new area_knob()
  deleteobject(testarea)

	test_channelswitcher()
	test_instrumentswitcher()
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


