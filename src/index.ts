const parser = require("../parser/parser.js")
import * as fs from 'fs'
import { argv } from 'process'

console.log(`Compiling ${argv[2]}`)
var data = fs.readFileSync(argv[2], {encoding: 'utf-8'})
var out = parser.parse(data)
out = '#include "../runtime/runtime.h"\n\n' + out
fs.writeFileSync("temp/temp.c", out)
console.log('Compiled successfully')