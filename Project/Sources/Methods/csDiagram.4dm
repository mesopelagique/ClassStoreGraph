//%attributes = {"shared":true,"preemptive":"capable"}
C_OBJECT:C1216($1; $2; $0)
If (Count parameters:C259=1)
	$0:=cs:C1710.ClassStoreDiagram.new($1)
End if 
If (Count parameters:C259=2)
	$0:=cs:C1710.ClassStoreDiagram.new($1; $2)
End if 