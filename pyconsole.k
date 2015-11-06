# Recive messages via OSC messages
# See python/keykit.py for usage.

#include contrib/GridMusic/start.k

# Default server value
PYCONSOLE_PORT = 3330
PYCONSOLE_HOSTNAME = "0.0.0.0"

# Global pointer to pyconsole object
# Target of osc_printf, see below.
Pyconsole = -1

# Flag to enable a few debugging messages. 
# Could be set by 
# /keykit/pyconsole/verbose TUIO message, too.
Pyconsole_verbose = 1

# Own interrupt function, unused
function no_interrupt(){

}

# Backup original printf handler
local_printf = printf

function local_print(...) {
	sep = ""
	for ( n=0; n<nargs(); n++ ) {
		local_printf("%s%s",sep,string(argv(n)))
		sep = " "
	}
	local_printf("\n")
}

# printf replacement for remote printing
function osc_printf(...) {
	if( Pyconsole != -1 ){
		s = sprintf(...)

		# 'Every' call is followed by a second one
		# with ... = "\n". Skip them seems to be ok.
		if( s == "\n" ) return()
		if( Pyconsole_verbose > 0 ) local_printf("Send '" + s + "'")
		Pyconsole.send(s)
	}else{
		local_printf(...)
	}
}

nn
class osc_console {
	method init(port, hostname) {
		if( nargs() < 2 ) hostname = PYCONSOLE_HOSTNAME
		if( nargs() < 1 ) port = PYCONSOLE_PORT

		$.osclistenport = port
		$.oschostname = hostname
		$.oscsendtarget = ["port"=(port+1), "server"="localhost"]
		$.open_tasks = [] # task id = key value, unused

		$.Hist = []
		$.Histindex = 0
		$.History = 0
		$.Modir = 0
		$.HFName = "pyconsole.log"

		printf = osc_printf
		Pyconsole = $
		Intrfunc = no_interrupt


		# s = string($.osclistenport)+"@"+Hostname
		# s = string($.osclistenport)+"@127.0.0.1"
		s = string($.osclistenport)+"@"+$.oschostname
		$.oscf = open(s,"rA","osc_listen")
		if ( $.oscf < 0 ) {
			local_print("Unable to listen on ",Osclisten," !?")
			$.osctid = -1
		} else {
			local_print("Listening for OSC on ",s," ...")
			# start loop for mmtt osc messages
			$.osctid = task $.osctask()
		}
		$.lastosc = 0 # unused
	}

	method handle_message(d){
		# print(d[0])
		if( d[0] == "/keykit/pyconsole/in" ){
			if( Pyconsole_verbose > 0 ) local_print("execute ", d[1])
			# Blocking evaluation
			# $.interpreter(d[1])

			# Unbocking evaluation
			tid = task $.interpreter(d[1])
			lock($)
			$.open_tasks[tid] = 1
			unlock($)
		}
		else if( d[0] == "/keykit/pyconsole/target" ){
			lock($)
			$.oscsendtarget["server"] = string(d[1])
			$.oscsendtarget["port"] = integer(d[2])
			if( Pyconsole_verbose > 0 ){
				local_print("Set pyconsole target to",
					string($.oscsendtarget["port"])+"@"+$.oscsendtarget["server"])
			}
			unlock($)
		}
		else if( d[0] == "/keykit/pyconsole/verbose" ){
			Pyconsole_verbose = integer(d[1])
		}
	}

	method osctask() {
		while ( (d=get($.oscf)) != Eof ) {

			# Bundled OSC messages leads to array structure, unsed
			if( typeof(d[0]) == "array" ){
				dnr = d["elements"]
				# Assume index enumeration 0,1,...
				for( i=0 ; i<dnr ; i++){
					$.handle_message(d[i])
				}
			}else{
				$.handle_message(d)
			}

			lock($)
			$.lastosc = Now
			unlock($)
		}
	}

	# Interpreter copied from loops.k::interploop
	method interpreter(cmd) {
		# Remap output into this object

		if ( cmd == Eof ){
			exit(0)
		}

		if ( cmd == Interrupt ) {
			if( Pyconsole_verbose > 0 ) local_print("<INTERRUPT>")
			return()
		}
		if ( cmd < 0 ) {
			return()
		}

		# $.History processing (revu et augmenté...)
		if ( substr(cmd,1,1)=="!") {
			theCmd = ""
			if (cmd=="!!") {
				if ($.Histindex > 0)
				{
					lock($)
					$.Histindex--
					theCmd = $.Hist[$.Histindex]
					unlock($)
				}
				else
				{
					# cons.printf("no history yet...\n")
					theCmd = ""
				}
			}
			else if (cmd=="!") { 				# liste

				if ($.Histindex > 0){
					for(hi = 0; hi < $.Histindex; hi++){
						# cons.printf("%d: %s\n",hi,$.Hist[hi])
					}
				}else{
					# cons.printf("no history yet...\n")
				}
				theCmd = ""
			}
			else if (cmd=="!!!") { 						# remise à zéro
				lock($)
				$.Histindex = 0
				unlock($)
				theCmd = ""
			}
			else if ((cmd=="!log") && $.Histindex > 0) {	# sauvegarde (KKlog.txt)
				logf = open($.HFName,"w")
				for(hi = 0; hi < $.Histindex; hi++)
				put(logf, sprintf("%d: %s\n",hi,$.Hist[hi]))
				close(logf)
				# cons.printf("%s\n",">>> $.History sauvegardée sous "+$.HFName)
				theCmd = ""							
			}
			else {
				which = split(cmd,"!")
				which = integer(which[0])
				if (which < 0){
					which = $.Histindex + which
				}
				if (which >= 0 && which <= $.Histindex) {
					theCmd = $.Hist[which]
				}
			}
			# if ( Inputistty && (theCmd != "") )
			# cons.printf("%s\n",">>> "+theCmd)
			cmd = theCmd
		}


		words = split(cmd," ")
		if ( sizeof(words) == 0 ){
			return()
		}

		lock($)
		$.Hist[$.Histindex++] = cmd
		unlock($)

		if ( words[0] == "print" ) {
			rest = substr(cmd,6)
			cmd = "print("+rest+")"
			words = split(cmd," ")
		}
		if (words[0] == "::") {
			lock($)
			$.Modir = 1-$.Modir		# bascule du mode direct 
			unlock($)
			cmd = "cmd"
		}
		else if ((substr(cmd,1,1) == ":")||($.Modir)) {	
			rest = substr(cmd,2-$.Modir)
			if (substr(rest,1,1) != "# ")
			{
				cmd = "print("+rest+")"
				words = split(cmd," ")
			}
		}
		if ( sizeof(split(cmd,"=")) > 1
		|| substr(cmd,1,5)=="print"
		|| words[0] == "delete"
		|| words[0] == "#define"
		|| words[0] == "#include" )
		{
			eval cmd
		}
		else {
			Cmd___tmp = 0
			eval "Cmd___tmp = " + cmd
			if ( typeof(Cmd___tmp) == "phrase" ) {
				t = realmidi(Cmd___tmp,Now)
				registop(t)
				# local_print("Ret: ",Cmd___tmp)
			}
		}
	}


	# TODO: buffer + bundle messages (bundles are defined in TUIO standard)
	method send(s){
		t = string($.oscsendtarget["port"])+"@"+string($.oscsendtarget["server"])
		f = open(t,"wb","osc_send")
		a = [0="/keykit/pyconsole/out",1=s]
		if( Pyconsole_verbose > 0 ) local_print("Sending OSC message:", a)
		mdep("osc","send",f,a)
		close(f)
	}

	method delete {
		if($.oscf > -1){
			close($.oscf)
			$.oscf = -1
		}
		kill($.osctid)
		$.osctid = -1
	}
}


function pyconsole(port, hostname){
	if( nargs() < 2 ) hostname = PYCONSOLE_HOSTNAME
	if( nargs() < 1 ) port = PYCONSOLE_PORT 
	LOWKEY=1
	enable_output()

	pycon = new osc_console(port, hostname)

	local_print("Press Ctrl+C to exit.")
	while (1) {
		sleeptill(Now+20b)
	}

	deleteobject(pycon);
}
