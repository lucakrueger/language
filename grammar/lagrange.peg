start
	= branch:(_ comment? _ top _ comment? _)* {
    	var ff = []
        for(var elem of branch) {
        	ff.push(elem[3])
        }
        return ff
    }

top
	= functionDef
    / overloadFunction

mid
	= index
	/ call
    / "(" _ op:operation _ ")" {return op}
    / array
    / set
    / Number
    / atom
	/ Name
    / string

call
	= branch:(Name "(" _ (_ mid _ ","?)* _ ")" "(" _ (_ Name _ ","?)* _ ")" "{" _ (operation / mid) _ "}") {
    	var args = []
        for(var elem of branch[3]) {
        	args.push(elem[1])
        }
        
        var fargs = []
        for(var elem of branch[8]) {
        	fargs.push(elem[1])
        }
        
        return {ident: 'callF', name: branch[0], values: args, fargs: fargs, block: branch[13]}
    }
	/ branch: (Name "(" _ (_ mid _ ","?)* _ ")") {
    	var args = []
        for(var elem of branch[3]) {
        	args.push(elem[1])
        }
        
        return {ident: 'call', name: branch[0], values: args}
    }

set
	= branch:("{" _ (_ Name _ setop _ mid)+ _ Name _ "|" _ (_ mid _ ","?)+ _ "|" _ mid _ "}") {
    	var values = []
        for(var elem of branch[2]) {
        	values.push({
            	ident: 'setAssignment',
                name: elem[1],
                op: elem[3],
                value: elem[5]
            })
        }
        
        var conditions = []
        for(var elem of branch[8]) {
        	conditions.push(elem[1])
        }
        
        return {ident: 'set', values: values, returning: branch[4], conditions: conditions, value: branch[12]}
    }
    / branch:("{" _ (_ Name _ setop _ mid)+ _ Name _ "|" _ mid _ "}") {
    	var values = []
        for(var elem of branch[2]) {
        	values.push({
            	ident: 'setAssignment',
                name: elem[1],
                op: elem[3],
                value: elem[5]
            })
        }
        
        var conditions = [{ident: 'atom', value: 'true'}]
        
        return {ident: 'set', values: values, returning: branch[4], conditions: conditions, value: branch[8]}
    }
    / branch:("[" _ (_ Name _ setop _ mid)+ _ "|" _ (_ mid _ ","?)+ _ "|" _ mid _ "]") {
    	var values = []
        for(var elem of branch[2]) {
        	values.push({
            	ident: 'setAssignment',
                name: elem[1],
                op: elem[3],
                value: elem[5]
            })
        }
        
        var conditions = []
        for(var elem of branch[6]) {
        	conditions.push(elem[1])
        }
        
        return {ident: 'setA', values: values, returning: null, conditions: conditions, value: branch[10]}
    }
    / branch:("[" _ (_ Name _ setop _ mid)+ _ "|" _ mid _ "]") {
    	var values = []
        for(var elem of branch[2]) {
        	values.push({
            	ident: 'setAssignment',
                name: elem[1],
                op: elem[3],
                value: elem[5]
            })
        }
        
        var conditions = [{ident: 'atom', value: 'true'}]
        
        return {ident: 'setA', values: values, returning: null, conditions: conditions, value: branch[6]}
    }

setop
	= "->"
    / "="

operation
	= branch:(mid _ (_ op _ mid)+) {
    	var vals = [branch[0]]
        var ops = []
        
        for(var elem of branch[2]) {
        	vals.push(elem[3])
            ops.push(elem[1])
        }
    
    	return {ident: 'operation', values: vals, ops: ops} 
    }

functionDef
	= def: (Name "(" _ (_ functionArg _ ","?)* _ ")" "(" _ (_ Name _ ","?)* _ ")" "{" _ Name _ "}" _ "=" _ (operation / mid)) {
    	var args = []
        for(var elem of def[3]) {
        	args.push(elem[1])
        }
        
        var fargs = []
        for(var elem of def[8]) {
        	fargs.push(elem[1])
        }
        
        return {ident: 'functionDefF', name: def[0], args: args, value: def[19], fargs: fargs, block: def[13]}
    }
	/ def: (Name "(" _ (_ functionArg _ ","?)* _ ")" _ "=" _ (operation)) {
    	var args = []
        for(var elem of def[3]) {
        	args.push(elem[1])
        }
        
        return {ident: 'functionDef', name: def[0], args: args, value: def[9]}
    }
    / def: (Name "(" _ (_ functionArg _ ","?)* _ ")" _ "=" _ (mid)) {
    	var args = []
        for(var elem of def[3]) {
        	args.push(elem[1])
        }
        
        return {ident: 'functionDef', name: def[0], args: args, value: def[9]}
    }

overloadFunction
	= branch:((op / "[]") "(" _ (_ (any / atom) _ ","?)+ _ ")" _ "->" _ functionDef) {
    	var values = []
        for(var elem of branch[3]) {
        	values.push(elem[1])
        }
        
        if(values.length > 2) {
        	values = [values[0], values[1]]
        }
        
        return {ident: 'overloadDef', values: values, op: branch[0], result: branch[9]}
    }

any
	= "?" {return {ident: 'any', value: '?'}}

functionArg
    = branch:(Name _ op _ functionArgType) {return {ident: 'argC', name: branch[0], op: branch[2], value: branch[4]}}
    / branch:functionArgType {return {ident: 'arg', value: branch}}

functionArgType
	= Number
    / atom
    / Name
    / string
    / array
    / arraySplit

Name
  	= text: (([a-z] / [A-Z] / [0-9] / [/.'_])+) {return {ident: 'name', value: text.join("")}}

array
	= branch:("[" _ (_ mid _ ","?)* _ "]") {
    	var values = []
        for(var elem of branch[2]) {
        	values.push(elem[1])
        }
        
        return {ident: 'array', values: values}
    }

index
	= branch:((call / ("(" _ operation _ ")") / Name) ("[" _ mid _ "]")+) {
    	var indices = []
        for(var elem of branch[1]) {
        	indices.push(elem[2])
        }
        
        var val = branch[0].ident
        if(val == undefined) {
        	val = branch[0][2]
        } else {
        	val = branch[0]
        }
    
    	return {ident: 'index', value: val, indices: indices}
    }

arraySplit
	= branch:("[" _ (_ (Number / atom / Name / string) _ "|"?)+ _ "]") {
    	var values = []
        for(var elem of branch[2]) {
        	values.push(elem[1])
        }
        
        return {ident: 'arraySplit', values: values}
    }

string "string"
  	= "\"" chars:char* "\"" { return {ident: 'string', value: chars.join("")} }

atom 
	= ":" nm:Name { return {ident: 'atom', value: nm.value} }

op
	= "++"
	/ "+"
    / "--"
    / "-"
    / "*"
    / "/"
   	/ "%"
    / "&&"
    / "&"
    / "#"
    / "@"
    / "?"
    / "<="
    / ">="
    / "<-"
    / "->"
    / "<<"
    / ">>"
    / "<"
    / ">"
    / "||"
    / "|"
    / "!!"
    / "!"
    / "=="
    / "="
    / "/="
    / "≈"
    / "±"
    / "..."
    / ".."
    / "."

char
  = unescaped
  / escape
    sequence:(
        "'"
      / "\\"
      / "/"
      / "b" { return "\b"; }
      / "f" { return "\f"; }
      / "n" { return "\n"; }
      / "r" { return "\r"; }
      / "t" { return "\t"; }
    )
    { return sequence; }

escape         = "\\"
quotation_mark = "\""
unescaped      = [\x20-\x21\x23-\x5B\x5D-\u10FFFF]

Number "number"	
	= left:[0-9]+ "." right:[0-9]+ { return {ident: 'number', value: parseFloat(left.join("") + "." +   right.join(""))}}
	/ left:[0-9]+ {return {ident: 'number', value: parseFloat(left.join(""))}}
  	/ "-" left:[0-9]+ "." right:[0-9]+ { return {ident: 'number', value: -parseFloat(left.join("") + "." +   right.join(""))}}
	/ "-" left:[0-9]+ {return {ident: 'number', value: -parseFloat(left.join(""))}}

comment
 	= Comment: ("/*" (!"*/" .)* "*/") {return {ident: 'comment', value: Comment.join("")}}

_ "whitespace"
  	= [ \t\n\r]*