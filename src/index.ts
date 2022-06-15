const parser = require("../parser/parser.js")
import * as fs from 'fs'
import { argv, exit } from 'process'

console.log(`Compiling ${argv[2]}`)
var data = fs.readFileSync(argv[2], {encoding: 'utf-8'})
try {
    var out = parser.parse(data)
} catch(e) {
    throw(e)
}
out.src = '#include "../runtime/runtime.h"\n\n' + out.src
fs.writeFileSync("temp/temp.c", out.src)
console.log('Compiled successfully')