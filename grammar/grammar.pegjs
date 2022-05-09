start
	= branch:(_ comment? _ top _ comment? _)* {
    	var ff = ""
        for(var elem of branch) {
        	//ff.push(elem[3])
            ff += elem[3]
        }
        return ff
    }

top
	= definition
    / extension

extension
	= branch:(_ Name _ op _ definition) {
    	var str = ""
    	if(branch[1].value == "main" && branch[3].value == "rarr") {
        	str += "dmain(" + branch[5].slice(8, branch[5].indexOf("(")) + ")"
        } else if(branch[3].value == "rarr") {
        	str += "value_t " + branch[1].value + "(value_t values[], unsigned int size){\n"
        	str += "\treturn " + branch[5].slice(8, branch[5].indexOf("(")) + "(values, size);\n"
        	str += "}"
        }
    
    	return branch[5] + str + "\n\n"
    }
    / branch:(_ Name _ op _ Name) {
    	var str = ""
        
        if(branch[3].value != "rarr") { return }
        
        str += "value_t " + branch[1].value + "(value_t values[], unsigned int size){\n"
        str += "\treturn " + branch[5].value + "(values, size);\n"
        str += "}"
        
        return str
    }

definition
	= branch:(_ Name _ ("|" _ definitionArgs _ "=" _ (operation / expr) _)+) {
    	var str = "value_t " + branch[1].value + "(value_t values[], unsigned int size) {\n"
        str += "\targs_t args = createArgs(values, size);\n\n"
        var counter = 0
        // go over cases
        for(var cse of branch[3]) {
        	str += "\tvalue_t values" + counter + "[] = {"
            str += cse[2].values
            str += "};\n"
            str += "\targs_t args" + counter + " = createArgs(values" + counter +", " + cse[2].values.length + ");\n"
            counter++
        }
        
        // check cases
        var operationName = "if"
        counter = 0
        for(var cse of branch[3]) {
        	str += "\t" + operationName +"(compareArgs(args, args" + counter + ")) {\n"
			// go over values, check for variables, initliaze them
            var i = 0
            for(var val of cse[2].raw) {
            	if(!(val.startsWith("String") || val.startsWith("Number") || val.startsWith("Atom") || val.startsWith("List")))
            	{//if(val[0] != "(")
                	// create and initialize variable
                	str += "\t\tvalue_t " + val + " = values[" + i + "];\n"
                }
                i++
            }
            
            // return
            str += "\t\treturn "
            str += cse[6]
            str += ";\n"
            
            str += "\t}\n"
            operationName = "else if"
            counter++
        }
        
        str += "}\n\n"
        return str
    }

definitionArgs
	= branch:("(" _ (_ expr _ ","?)* _ ")") {
    	var args = []
        var raw = []
        for(var elem of branch[2]) {
        	raw.push(elem[1])
        	//if(elem[1][0] != "(")
            var val = elem[1]
            if(!(val.startsWith("String") || val.startsWith("Number") || val.startsWith("Atom") || val.startsWith("List")))
            {
            	//args.push("(value_t){ANY, &(any_t){1}}")
                args.push("Any()")
                continue
            }
        	args.push(elem[1])
        }
        
        return {ident: "defargs", values: args, raw: raw}
    }

expr
	= call
    / index
    / branch:("(" operation ")") {return branch[1]}
    / branch:string {
    		return 'String("' + branch.value + '",' + branch.value.length + ")"
    		/*return '(value_t){STRING, &(string_t){"'+ 
            	branch.value + '",' + branch.value.length
            +'}}'*/
      	}
    / branch:Number {
    	var num = branch.value
        if(!(num+"").includes(".")) {
        	num = num + "."
        }
        return "Number(" + num + "f)"
		//return "(value_t){NUMBER, &(number_t){"+
    	//	num + "f"
        //+"}}"
        }
    / branch:Name {return branch.value}
    / branch:atom {
    		/*return '(value_t){ATOM, &(atom_t){"'+ 
            	branch.value + '",' + branch.value.length
            +'}}'*/
            return 'Atom("' + branch.value + '",' + branch.value.length + ")"
      	}
	/ branch:list {return branch}

exprdown
	= call
    / branch:("(" operation ")") {return branch[0]}
    / branch:Name {return branch.value}

call
	= branch:(Name "(" ((operation / expr) _ ","? _)* ")") {
    	var str = branch[0].value + "((value_t[]){"
    	
        for(var elem of branch[2]) {
        	str += elem[0]
            if(elem[2] != null) {
            	str += elem[2]
            }
        }
        
        str += "}," + branch[2].length + ")"
    	return str
    }

index
	= branch:(exprdown "[" _ expr _ "]") {
    	return "Index(" + branch[0] + ", (" + branch[3] + "))"
    }

operation
	= branch:(expr _ (_ op _ expr)+) {
    	var values = [branch[0]]
        var ops = []
        for(var elem of branch[2]) {
        	values.push(elem[3])
            ops.push(elem[1])
        }
        
        // 5, 8, 9
        // +, -
        // op_plus(op_minus(5, 8), 9)
        // op_any(b, a)!!!!
        
        values = values.reverse()
        ops = ops.reverse()
        
        var str = ""
        function getSource(i) {
       		if(i >= ops.length) {
            	str += "("+values[i]+")"
            	return
            }
        	str += "op_"+ops[i].value+"(("+values[i]+"),"
            getSource(i+1)
        }
        getSource(0)
        for(var i = 0; i < ops.length; i++) { str += ")" }
        
        return str
    }
    / "{" _ branch:(expr _ (_ op _ expr)+) _ "}" args:("(" _ (_ expr _ ","?)* _ ")") {
    	// common factor -> call
    	var values = [branch[0]]
        var ops = []
        for(var elem of branch[2]) {
        	values.push(elem[3])
            ops.push(elem[1])
        }
        
        // 5, 8, 9
        // +, -
        // op_plus(op_minus(5, 8), 9)
        // op_any(b, a)!!!!
        
        // process args
        var str2 = "("
        for(var elem of args[2]) {
        	str2 += elem[1]
            if(elem[3] != null) {
            	str2 += args[3]
            }
        }
        str2 += ")"
        
        values = values.reverse()
        ops = ops.reverse()
        
        var str = ""
        function getSource(i) {
       		if(i >= ops.length) {
            	str += "("+values[i]+")" + str2
            	return
            }
        	str += "op_"+ops[i].value+"(("+values[i]+")" + str2 +","
            getSource(i+1)
        }
        getSource(0)
        for(var i = 0; i < ops.length; i++) { str += ")" }
        
        return str
    }
    / "{" _ branch:(expr _ (_ op _ expr)+) _ "}" args:("[" _ expr _ "]") {
    	// common factor -> index
    	var values = [branch[0]]
        var ops = []
        for(var elem of branch[2]) {
        	values.push(elem[3])
            ops.push(elem[1])
        }
        
        // 5, 8, 9
        // +, -
        // op_plus(op_minus(5, 8), 9)
        // op_any(b, a)!!!!
        
        values = values.reverse()
        ops = ops.reverse()
        
        var str = ""
        function getSource(i) {
       		if(i >= ops.length) {
            	str += "Index(("+values[i]+"),(" + args[2] + "))"
            	return
            }
        	str += "op_"+ops[i].value+"(Index(("+values[i]+"),(" + args[2] +"))" +","
            getSource(i+1)
        }
        getSource(0)
        for(var i = 0; i < ops.length; i++) { str += ")" }
        
        return str
    }
    

Name
  	= text: (([a-z] / [A-Z] / [0-9] / [/.'_])+) {return {ident: 'name', value: text.join("")}}

string "string"
  	= "\"" chars:char* "\"" { return {ident: 'string', value: chars.join("")} }

atom 
	= ":" nm:Name { return {ident: 'atom', value: nm.value} }

list
	= branch:("[" _ (expr _ ","? _)* _ "]") {
    	var src = ""
        for(var elem of branch[2]) {
        	src += elem[0]
            if(elem[2] != null) {
            	src += elem[2]
            }
        }
        return "List(" + "((value_t[]){" + src + "})," + branch[2].length + ")"
    }

op
	= "+++" {return {ident: "op", value: "plusplusplus"}}
	/ "++" {return {ident: "op", value: "plusplus"}}
	/ "+" {return {ident: "op", value: "plus"}}
    / "***" {return {ident: "op", value: "starstarstar"}}
    / "**" {return {ident: "op", value: "starstar"}}
    / "*" {return {ident: "op", value: "star"}}
    / "///" {return {ident: "op", value: "slashslashslash"}}
    / "//" {return {ident: "op", value: "slashslash"}}
    / "/" {return {ident: "op", value: "slash"}}
    / "%%%" {return {ident: "op", value: "percpercperc"}}
    / "%%" {return {ident: "op", value: "percperc"}}
   	/ "%" {return {ident: "op", value: "perc"}}
    / "&&&" {return {ident: "op", value: "andandand"}}
    / "&&" {return {ident: "op", value: "andand"}}
    / "&" {return {ident: "op", value: "and"}}
    / "###" {return {ident: "op", value: "hashhashhash"}}
    / "##" {return {ident: "op", value: "hashhash"}}
    / "#" {return {ident: "op", value: "hash"}}
    / "@@@" {return {ident: "op", value: "atatat"}}
    / "@@" {return {ident: "op", value: "atat"}}
    / "@" {return {ident: "op", value: "at"}}
    / "$$$" {return {ident: "op", value: "dollardollardollar"}}
    / "$$" {return {ident: "op", value: "dollardollar"}}
    / "$" {return {ident: "op", value: "dollar"}}
    / "§§§" {return {ident: "op", value: "parparpar"}}
    / "§§" {return {ident: "op", value: "parpar"}}
    / "§" {return {ident: "op", value: "par"}}
    / ":::" {return {ident: "op", value: "coloncoloncolon"}}
    / "::" {return {ident: "op", value: "coloncolon"}}
    / ":" {return {ident: "op", value: "colon"}}
    / ";;;" {return {ident: "op", value: "scolonscolonscolon"}}
    / ";;" {return {ident: "op", value: "scolonscolon"}}
    / ";" {return {ident: "op", value: "scolon"}}
    / "^^^" {return {ident: "op", value: "upupup"}}
    / "^^" {return {ident: "op", value: "upup"}}
    / "^" {return {ident: "op", value: "up"}}
    / "°°°" {return {ident: "op", value: "degdegdeg"}}
    / "°°" {return {ident: "op", value: "degdeg"}}
    / "°" {return {ident: "op", value: "deg"}}
    / "???" {return {ident: "op", value: "questquestquest"}}
    / "??" {return {ident: "op", value: "questquest"}}
    / "?" {return {ident: "op", value: "quest"}}
    / "<=" {return {ident: "op", value: "leq"}}
    / ">=" {return {ident: "op", value: "geq"}}
    / "<-" {return {ident: "op", value: "larr"}}
    / "->" {return {ident: "op", value: "rarr"}}
    / "<<" {return {ident: "op", value: "Larr"}}
    / ">>" {return {ident: "op", value: "Rarr"}}
    / "<" {return {ident: "op", value: "less"}}
    / ">" {return {ident: "op", value: "greater"}}
    / "---" {return {ident: "op", value: "minusminusminus"}}
    / "--" {return {ident: "op", value: "minusminus"}}
    / "-" {return {ident: "op", value: "minus"}}
    / "|||" {return {ident: "op", value: "ororor"}}
    / "||" {return {ident: "op", value: "oror"}}
    / "|" {return {ident: "op", value: "or"}}
    / "!!!" {return {ident: "op", value: "exclexclexcl"}}
    / "!!" {return {ident: "op", value: "exclexcl"}}
    / "!" {return {ident: "op", value: "excl"}}
    / "===" {return {ident: "op", value: "eqeqeq"}}
    / "==" {return {ident: "op", value: "eqeq"}}
    / "=" {return {ident: "op", value: "eq"}}
    / "/=" {return {ident: "op", value: "neq"}}
    / "≈" {return {ident: "op", value: "req"}}
    / "~~~" {return {ident: "op", value: "tildetildetilde"}}
    / "~~" {return {ident: "op", value: "tildetilde"}}
    / "~" {return {ident: "op", value: "tilde"}}
    / "±" {return {ident: "op", value: "pm"}}
    / "..." {return {ident: "op", value: "dotdotdot"}}
    / ".." {return {ident: "op", value: "dotdot"}}
    / "." {return {ident: "op", value: "dot"}}
    / "'''" {return {ident: "op", value: "markmarkmark"}}
    / "''" {return {ident: "op", value: "markmark"}}
    / "'" {return {ident: "op", value: "mark"}}

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