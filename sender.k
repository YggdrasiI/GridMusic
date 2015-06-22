# Listener class. 
class sender{
	method init(){
		$.listener = []
	}

	method notify(val){
		for( l in $.listener){
			if($.listener[l] != ""){
				$.listener[l][0].($.listener[l][1])(val)#variant for given function name
			}
		}
	}

	# signature of func: obj, method name (two arguments)
	method addListener(obj,funk){
		$.listener[sizeof($.listener)] = [0=obj,1=funk]
	}

	method removeListener(funk){
		for( l in $.listener){
			if($.listener[l] != "" && $.listener[l][0] == funk){
				$.listener[l] = ""
			}
		}
	}


}
