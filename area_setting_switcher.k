# Allow the switch between different layers. 
# 0. Init area and assoziate areaids with setting functionhandler.
# 1. Press this area
# 2. Press other area to load a new setting. The old areas will be deleted.
class area_setting_switcher{
	method init(kstore, settings) {

		$.inherit( new area(3,1,5) )
		$.update = $.update_handler
		$.kstore = kstore
		$.real_areas = []
		if(nargs() > 1){
			$.settings = settings
		}else{
			$.settings = $.defaultsettings()
		}

		$.active = 0
		$.timestamp = Now 

		$.switch_area = new area_selector();
		#$.switch_area.set_handler($.switch_handler)
		$.switch_area.set_obj($)
	}

	method defaultsettings(){
		s = [1=setting1,2=setting2,4=setting3,5=setting4,6=setting5]
		return(s)
	}

	method update_handler(areaid,handid,x,y,z) {
		lock($)
		ix = floor( ($.dimX)*x)
		iy = floor( ($.dimY)*z)
		iz = floor( ($.dimZ)*y)

		if( iz > 2 && ($.active == 0 || Now - $.timestamp > 1b) ){
			$.active = 1
			$.timestamp = Now
			# previous, same or next setting index
			$.areaid = areaid
			if( ("looper" in $.kstore) && sizeof($.real_areas) == 0 ) {
				o = $.kstore["looper"]
				$.real_areas = o.get_areas()
				print("!!                 Select Setting                !!")
				realtime('co3v100')
				areas2 = []
				for( i in $.real_areas ){
					if( i != areaid)
					areas2[i] = $.switch_area
					else
					areas2[i] = $
				}

				$.switch_area.wait(Now+1b/2)
				o.set_areas(areas2)
				#sleeptill(Now+1b)
			}
			#realtime('eo3v100')
		}else if( iz < 2 ){
			$.active = 0
		}
		unlock($)
	}

	method switch_handler(areaid, handid, x,y,z){
		lock($)
		print("Selected area: ",areaid)

		if( typeof($.settings[areaid]) == "function" ){	
			realtime('co4v100')

			areas1 = ($.settings[areaid])(0)
			#remove element with  this areaid
			areas2 = []
			for( i in areas1){
				if( i != $.areaid ){
					areas2[i] = areas1[i]
				}else{
					deleteobject(areas1[i])
					areas2[i] = $
				}
			}

			#set new areas and delete old objects. Exclude this area.
			#tmp = $.kstore["looper"].get_areas(areas2)
			tmp = $.real_areas
			$.kstore["looper"].set_areas(areas2)
			for( i in tmp){
				if( i != $.areaid ){
					deleteobject(tmp[i])
				}
			}

			#block some time
			sleeptill(Now+10)
		}else{
			print("No setting on this area set.")
			$.kstore["looper"].set_areas($.real_areas)
		}
		print("Ende")
		$.real_areas = []
		unlock($)
	}

	method delete(){
		if($.switch_area != -1)
		deleteobject($.switch_area)
	}

}


# Dummy class as touch detector in area_setting_switcher. 
class area_selector{
	method init() {
		$.inherit( new area(1,1,5) )
		$.update = $.update_handler
		#$.select = $.default_handler
		$.obj = $
		$.active = 0
		$.timestamp = Now 
		$.twait = Now+1b
	}

	method update_handler(areaid,handid,x,y,z) {
		ix = floor( ($.dimX)*x)
		iy = floor( ($.dimY)*z)
		iz = floor( ($.dimZ)*y)

		lock($)
		if( iz > 2 && ($.active == 0 || Now - $.timestamp>1b ) && Now>$.twait ){
			$.active = 1
			$.timestamp = Now
			#callback
			#task $.select(areaid, handid, x,y,z) 
			$.obj.switch_handler(areaid, handid, x,y,z)
			#sleeptill(Now+1b)
		} else if( iz < 2){
			$.active = 0
		}
		unlock($)
	}

	method switch_handler(areaid, handid, x,y,z){
		print("Selected area: ",areaid," (default handler)")
	}

	method set_handler(h){
		$.select = h;
	}
	method set_obj(o){
		lock($)
		$.obj = o
		unlock($)
	}

	method wait(t){
		lock($)
		$.twait = t
		$.active = 0
		unlock($)
	}

}
