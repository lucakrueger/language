const parser = require("../parser/parser.js")
import * as fs from 'fs'
import { argv, exit } from 'process'

console.log(`Compiling ${argv[2]}`)
var data = fs.readFileSync(argv[2], {encoding: 'utf-8'})
try {
    var out = parser.parse(data)
    var alreadyImported = new Map<String, Boolean>([])
    var i = 0
    var sze = out.uses.length
    while(i < sze) {
        var use = out.uses[i]
        console.log(alreadyImported.get(use))
        if(alreadyImported.get(use) != undefined) {
            i++
            continue
        }

        var importedData = fs.readFileSync(use, {encoding: 'utf-8'})
        var imported = parser.parse(importedData)
        out.src = imported.src + out.src
        out.uses.push(...imported.uses)
        sze = out.uses.length
        alreadyImported.set(use, true)
        i++
    }
} catch(e) {
    throw(e)
}
out.src = '#include "../runtime/runtime.h"\n\n' + out.src
fs.writeFileSync("temp/temp.c", out.src)
console.log('Compiled successfully')