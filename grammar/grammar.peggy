{
	// Global Initializer
    var sets = []
    var setsNames = []
    var types = [] // holds type data
    var funs = []
    var uses = []
    
    var main = ""
    var lookForEntry = false
    
    var attributes = []
    
    function makeid(length) {
   		var result           = '';
      	var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
      	var charactersLength = characters.length;
      	for ( var i = 0; i < length; i++ ) {
      		result += characters.charAt(Math.floor(Math.random() * charactersLength));
      	}
   		return result;
	}
}

start
	= branch:(_ comment? _ top _ comment? _)* {
    	var ff = ""
        for(var elem of branch) {
        	//ff.push(elem[3])
            ff += elem[3]
        }
        
        var out = ""
        /*var newSets = []
        var c = 1
        for(var s of sets) {
        	/*if((c + 1) % 2 == 0) {
            	//newSets.push(s)
                out += s + "\n"
            }*/
            //out += s + "\n"
            //c++
        //}*/*/
        
        for(var i = 0; i < funs.length; i++) {
        	out += "value_t " + funs[i] +"(value_t values[], unsigned int size);\n"
        }
        out += "\n"
        
        var setsout = ""
        for(var c = 0; c < sets.length; c++) {
        	if(c % 2 == 0) {
            	continue
            }
        	setsout += sets[c] + "\n"
            out += setsNames[c] + ";\n"
        }
        
        out += "\n" + setsout + "\n"
        
        for(var t of types) {
        	out += t + "\n"
        }
        
        out = out + "\n\n" + ff
        if(main != "") {
        	out += "dmain(" + main + ")"
        }
        
        return {
        	src: out,
            uses: uses,
            attributes
        }
        //return out
        //return ff
    }

top
	= definition
    / typedef
    / extension
    / attributes

attributes
	= "@use " chars:char* _ {
    	uses.push(chars.join("")) // Ignore use, recognized by preprocessor
    	return ""
    }
    / "@" chars:Name _ "(" _ args:(_ expr _)* _ ")" _ {
    	var a = []
        for(var ar of args) {
        	a.push(ar[1])
        }
    	attributes.push({
        	attr: chars.value,
            args: a
        })
    	return ""
    }
    / "@" chars:Name _ {
    	// attribute without args
        attributes.push({
        	attr: chars.value,
            args: []
        })
        return ""
    }
    / "@ :: " def:definition {
    	return def
    }

typedef
	= "type" _ "::" _ tname:Name _ fields:(_ "|" _ Name _ ("?" / ("=" _ expr)) _ )+ _ {
    	// Type Definition
        var type = ""
        
        // create constructor (wrapper)
        type += "value_t " + tname.value + "Wrapper("
        
        var fieldNames = "\tchar **fields = malloc(sizeof(char *) * " + fields.length + ");\n"
        var assignments = "\tvalue_t *values = malloc(sizeof(value_t) * " + fields.length + ");\n"
        var count = 0
        for(var f of fields) {
        	// field names
            fieldNames += "\tfields[" + count + "] = " + '"' + f[3].value + '";\n'
        
        	// initializers
        	if(f[5][0] == "?") {
            	type += "value_t " + f[3].value + ", "
                assignments += "\tvalues[" + count + "] = " + f[3].value + ";\n"
            } else if(f[5][0] == "=") {
            	//initializers += "\tvalue_t " + f[3].value + " = " + f[5][2] + ";\n"
            	assignments += "\tvalues[" + count + "] = " + f[5][2] + ";\n"
            }
            
            count++
        }
        type = type.slice(0, -2)
        type += ") {\n"
        type += fieldNames + "\n"
        type += assignments + "\n"
        
        type += "\tvalue_t temp = Class(" + '"' + tname.value + '"' +", " + (tname.value.length + 1) + ", " + fields.length + ", fields, values);\n"
        type += "\treturn temp;\n"
        
        type += "}\n"
        
        var con = "value_t " + tname.value + "(value_t *args, unsigned int size) {\n"
        con += "\treturn " + tname.value + "Wrapper("
        
        var c = 0
        for(var f of fields) {
        	if(f[5][0] == "?") {
            	con += "args[" + c + "], "
                c++
            }
        }
        con = con.slice(0, -2)
        
        con += ");\n"
        con += "}\n"
        
        type += con
        types.push(type)
        
        return ""
    }

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
        
        funs.push(branch[1].value)
        /*if(lookForEntry == true) {
        	main = branch[1].value
        }*/
        // go over attributes, add them
        for(var a of attributes) {
        	switch(a.attr) {
            	case "entry":
                	main = branch[1].value
                    break
                case "deprecated":
                	str += '\tprintf("%s", "Warning, function '+ "'" + branch[1].value + "'" +' is deprecated\\n");\n'
                	break
               	default:
                	str += "\tvalue_t a_" + a.attr + " = " + a.attr + "((value_t[]){"
                    for(var attrarg of a.args) {
                    	str += attrarg + ", "
                    }
                    if(a.args.length != 0) {
                        str = str.slice(0, -2)
                    }
                    str += "}, " + a.args.length + ");\n"
                    break
            }
        }
        
        attributes = []
        
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
            
            // go over defexprs
            // initialize
            for(var def of cse[2].defs) {
            	// initialize temp value
                var id = "temp_" + makeid(8)
                str += "\t\tvalue_t " + id + " = " + def.value + ";\n"
                // generate specific code
            	switch(def.expr.ident) {
                	case "listsplit":
                    	var count = 0
                        for(var name of def.expr.names) {
                        	if(count < (def.expr.names.length - 1)) {
                            	// all besides last element
                                //str += "\t\tvalue_t " + name.value + " = " + id + "[" + count + "];\n"
                            	str += "\t\tvalue_t " + name.value + " = " + "getList(" + id + ").values[" + count + "];\n"
                            } else {
                            	// last element
                                str += "\t\tvalue_t " + name.value + " = EmptyList(len(" + id + ") - " + count + ");\n"
                            	
                                var iterId = makeid(4)
                            	str += "\t\tfor(int " + iterId + " = " + count +"; " + iterId + " < len(" + id + "); " + iterId + "++) {\n"
                            	//str += "\t\t\tgetList(" + name.value + ").values[" + iterId + " - " + count +"] = " + id + "[" + iterId + "];\n"
                                str += "\t\t\tgetList(" + name.value + ").values[" + iterId + " - " + count +"] = getList(" + id + ").values[" + iterId + "];\n"
                                str += "\t\t}\n"
                            }
                        	count++
                        }
                    	break
                	case "name":
                    	str += "\t\tvalue_t " + def.expr.value + " = " + id + ";\n"
                    	break
                }
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
	= branch:("(" _ (_ expr _ ","?)* _ ")" _ (_ ","_ defexpr _ ":" _ expr)*) {
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
        
        var defs = []
        for(var d of branch[6]) {
        	defs.push({
            	expr: d[3],
                value: d[7]
            })
        }
        
        return {ident: "defargs", values: args, raw: raw, defs: defs}
    }

setexpr
	= "{" _ vars:("?"? Name _)+ _ "|" _ inits:("(" _ Name _ op _ expr _ ")" _)+ _ "|" _ ops:("(" _ operation _ ")"_ )+ _ "|" _ result:expr _ "}" {
    	
        var wrappedIter = makeid(8)
        var variableNames = []
        for(var v of vars) {
        	if(v[0] != undefined) {
            	wrappedIter = v[1].value // value with prefix "?" is wrapping iter
            } else {
        		variableNames.push(v[1].value)
            }
        }
        
        // search for iterator
        var iterator = "none"
        var iteratorValue = ""
        for(var init of inits) {
        	if(init[4].value == "larr") {
            	iterator = init[2].value
                iteratorValue = init[6]
            }
        }
        
        // build new function
        // add to sets
        var temp = ""
        var funcName = "set_" + makeid(6)
        //setsNames.push(funcName)
        
        // build declaration
        temp += "value_t " + funcName + "(value_t iteratorList, "
        for(var name of variableNames) {
        	temp += "value_t " + name + ","
        }
        temp = temp.slice(0, -1)
        temp += ") {\n"
        setsNames.push(temp.slice(0, -3))
        
        // initialize
        temp += "\tvalue_t elem = None();\n"
        temp += "\tvalue_t returning = EmptyList(getList(" + "iteratorList" + ").size);\n"
        temp += "\tint curr = 0;\n"
        temp += "\tfor(int iter = 0; iter < getList(" + "iteratorList" + ").size; iter++) {\n"
        temp += "\t\telem = getList(iteratorList).values[iter];\n"
        temp += "\t\tvalue_t " + wrappedIter + " = Number(" + "(float)iter" + ");\n"
        temp += "\t\t" + iterator + " = elem;\n"
        
        temp += "\t\tif("
        for(var o of ops) {
        	temp += " isTrue(" + o[2] + ") &&"
        }
        temp = temp.slice(0, -2)
        temp += ") {\n"
        temp += "\t\t\tgetList(returning).values[curr] = " + result + ";\n"
        temp += "\t\t\tcurr++;\n"
        temp += "\t\t}\n"
        temp += "\t}\n"
        
        temp += "\treturn sliceList(returning, curr);\n"
        
        temp += "}"
        
        sets.push(temp)
        
        // returned
        var retStr = ""
        
        retStr += funcName + "(" + iteratorValue + ", "
        for(var it of inits) {
        	retStr += it[6] + ","
        }
        retStr = retStr.slice(0, -1)
        retStr += ")"
        
        return retStr
    }

defexpr
	= Name
    / listsplit

expr
	= call
    / index
    / field
    / branch:("(" operation ")") {return branch[1]}
    / commonFac
    / setexpr
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

field
	= name:Name ":" field:atom {
    	return "op_colon(Atom(" + '"' + field.value + '", ' + (field.value.length + 0) + '), ' + name.value + ")"
    }

listsplit
	= "[" _ first:Name _ other:(_ "|" _ Name)+ _ "]" {
    	var names = [first]
        
        for(var name of other) {
        	names.push(name[3])
        }
    
    	return {ident: "listsplit", names: names} 
    }

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
commonFac
    = "{" _ branch:(expr _ (_ op _ expr)+) _ "}" args:("(" _ (_ expr _ ","?)* _ ")") {
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
        var str2 = "((value_t[]){"
        var argCounter = args[2].length
        for(var elem of args[2]) {
        	str2 += elem[1]
            if(elem[3] != null) {
            	str2 += args[3]
            }
            str2 += ", "
        }
        str2 = str2.slice(0, -2)
        str2 += "}, " + argCounter + ")"
        
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