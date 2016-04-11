# ----------------------------------------------
# Test how $ and $$ changes after function calls
# Usage of $$ should be prefered.

class classA{
  method init(){
    $.var = "a"
    $.var1 = "aa"
  }
  # Only defined in classA
  method bar(){
    print("\tbarA")
    print("\tClasses of $ and $$:", $.classof(), $$.classof())
		#print("\tVariables of both contextes available, too.")
		#print("\t$.var = ", $.var, ", $$.var =", $$.var, ", $$.var2 = ", $$.var2)
    print("")
    print("\tCall $.foo()...")
    $.foo()
    print("\tCall $$.foo()...")
    $$.foo()
  }
  # Overloading. Defined in classA and classB
  method foo(){
    print("\t\tfooA")
    print("\t\tClasses of $ and $$:", $.classof(), $$.classof())
  }
	# Return name of (top level) class.
	method classof {
		return($$.class)
	}
  method test_short(tab, recursive){
    print(tab, $.classof(), $$.classof())
		if( recursive > 0){
			if( $.classof() != $$.classof() ){
				$.test_short(tab+"\t", recursive-1)
			}
			$$.test_short(tab+"\t", recursive-1)
		}
	}
}
class classB{
  method init(){
    $.var = "b"
    $.var2 = "bb"
    $.inherit( new classA() )
  }
  # Overloading. Defined in classA and classB
  method foo(){
    print("\t\tfooB")
    print("\t\tClasses of $ and $$:", $.classof(), $$.classof())
  }
  method test(){
    print("Classes of $ and $$:", $.classof(), $$.classof())
    print("==> $.var = ", $.var, ", $$.var =", $$.var)
    print("")
    print("Call classA.bar with $.bar()...")
    $.bar()
    print("Call classA.bar with $$.bar()...")
    $$.bar()
    print("")
    print("")
    print("Call classB.foo with $.foo()...")
    $.foo()
    print("Call classA.foo directly is impossible, but could be done with...")
		for( child in $.inherited() ){
			if( child.classof() == "classA" ){
				child.foo()
			}
		}
  }
  method test2(){
		#print($.classof(), $$.classof())
		if( $.classof() != $$.classof() ){
			$.test_short("\t", 2)
		}
    $$.test_short("\t", 2)
  }
}

function test_overloads(){
  b = new classB()
  b.test()
  #b.var1 = "cc"
	#b.var2 = "dd"
	print("")
	print("More compact output of class names...")
	print("This shows that the usage of $$ in most cases should be prefered.")
	b.test2()
  deleteobject(b)
}

