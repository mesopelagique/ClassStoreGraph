
Class constructor($classStore : Object; $start_with_root_class : Object)
	// Initialize with a class store
	This:C1470.cs:=$classStore
	This:C1470.ignore:=New collection:C1472()
	If ($start_with_root_class#Null:C1517)
		This:C1470.ignore_all_but_this_class_hier($start_with_root_class)
	End if 
	
	
Function ignore_all_but_this_class_hier($root_class : Object)
	var $full_class_list : Collection
	$full_class_list:=New collection:C1472("Object")
	
	var $class_children_list : Object
	$class_children_list:=New object:C1471
	
	var $class : Object
	var $name; $parent_name : Text
	For each ($name; This:C1470.cs)
		$full_class_list.push($name)
		$class:=This:C1470.cs[$name]
		If ($class.superclass=Null:C1517)
			continue
		End if 
		
		$parent_name:=$class.superclass.name
		If ($class_children_list[$parent_name]=Null:C1517)
			$class_children_list[$parent_name]:=New collection:C1472()
		End if 
		$class_children_list[$parent_name].push($name)
	End for each 
	$full_class_list:=$full_class_list.distinct()  // use this to sort
	
	var $class_list : Collection
	$class_list:=New collection:C1472($root_class.name)
	
	// find all the upstream classes
	var $child_name : Text
	$child_name:=$root_class.name
	While ($child_name#"")
		If (This:C1470.cs[$child_name].superclass#Null:C1517)
			$class_list.push(This:C1470.cs[$child_name].superclass.name)
			If (This:C1470.cs[$child_name].superclass#Null:C1517)  // get next parent
				$child_name:=This:C1470.cs[$child_name].superclass.name
			Else 
				$child_name:=""
			End if 
		Else 
			$child_name:=""
		End if 
	End while 
	
	
	// find all the downstream classes
	var $class_names_to_add : Collection
	If ($class_children_list[$root_class.name]#Null:C1517)
		$class_names_to_add:=$class_children_list[$root_class.name].copy()
	Else 
		$class_names_to_add:=New collection:C1472()
	End if 
	While ($class_names_to_add.length>0)
		$parent_name:=$class_names_to_add.pop()
		$class_list.push($parent_name)
		If ($class_children_list[$parent_name]#Null:C1517)
			$class_names_to_add.combine($class_children_list[$parent_name].copy())
		End if 
	End while 
	$class_list:=$class_list.distinct()
	
	var $alt : Collection
	$alt:=New collection:C1472()
	var $num_in; $num_out : Integer
	This:C1470.ignore:=New collection:C1472()
	For each ($name; $full_class_list)
		If ($class_list.indexOf($name)<0)  // class not in the hier we want to see?
			This:C1470.ignore.push($name)
			$num_out+=1
		Else 
			$alt.push($name)
			$num_in+=1
		End if 
	End for each 
	
	
Function formats()->$formats : Collection
	/// Return the list of supported format 
	$formats:=New collection:C1472("graphviz"; "mermaid")
	
Function graphviz()->$dot : cs:C1710.Diagram
	$dot:=This:C1470.dot()
	
Function dot()->$diagram : cs:C1710.Diagram
	/// Return class diagram in dot format
	var $output : Text
	$output:="digraph{\n"
	
	If (This:C1470.ignore=Null:C1517)
		This:C1470.ignore:=New collection:C1472()
	End if 
	
	C_TEXT:C284($className)
	For each ($className; This:C1470.cs)
		If (This:C1470.ignore.indexOf($className)<0)
			$output:=$output+$className+"[shape=box];\n"
		End if 
	End for each 
	
	C_OBJECT:C1216($class)
	For each ($className; This:C1470.cs)
		If (This:C1470.ignore.indexOf($className)<0)
			$class:=This:C1470.cs[$className]
			If ($class.superclass#Null:C1517)
				If (This:C1470.ignore.indexOf($class.superclass.name)<0)
					$output:=$output+$className+"->"+$class.superclass.name+";\n"
				End if 
			End if 
		End if 
	End for each 
	$output:=$output+"\n"
	$output:=$output+"}"
	
	$diagram:=cs:C1710.Diagram.new("graphviz"; $output)
	
Function mermaid()->$diagram : cs:C1710.Diagram
	/// Return class diagram in mermaid format
	
	var $output : Text
	$output:="classDiagram\n"
	
	If (This:C1470.ignore=Null:C1517)
		This:C1470.ignore:=New collection:C1472()
	End if 
	
	var $className : Text
	For each ($className; This:C1470.cs)
		If (This:C1470.ignore.indexOf($className)<0)
			$output:=$output+"\tclass "+$className+" {\n"
/*
For each($functionName;$class.functions)
$output:=$output+"\t\t"+$className+":"+$functionName+"() \n"
End for each 
*/
			$output:=$output+"\t}\n"
		End if 
	End for each 
	
	var $class : Object
	For each ($className; This:C1470.cs)
		If (This:C1470.ignore.indexOf($className)<0)
			$class:=This:C1470.cs[$className]
			If ($class.superclass#Null:C1517)
				If (This:C1470.ignore.indexOf($class.superclass.name)<0)
					$output:=$output+$class.superclass.name+" <|-- "+$className+"\n"
				End if 
			End if 
		End if 
	End for each 
	
	$output:=$output+"\n"
	
	$diagram:=cs:C1710.Diagram.new("mermaid"; $output)
	