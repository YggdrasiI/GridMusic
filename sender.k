# Verwaltung von Listenern mit diesem Unterobject
# im Sende-Object ist addListener mit mit der gleichnamigen Methode aus dieser Klasse zu verbinden.
class sender{
	method init(){
		$.listener = []
	}

	method notify(val){
		for( l in $.listener){
			if($.listener[l] != ""){
				$.listener[l][0].($.listener[l][1])(val)#variant for given function name
				#$.listener[l][1]( $.listener[l][0], val )#wrong way?!
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
