#!/bin/sh

# Usage: tests/test-de-humanize-bytes.sh
# (i.e., at the project's root folder)

utils_path="$(realpath $(dirname $0))/.."
num_amt=50 # How many numbers to test?

#region Shellscript fn: check_outputs
check_outputs(){
    # Param $1: cross-language input
    # Param $2: Node.js output
    # Param $3: Ruby output
    # Param $4: Python output
    # Param $5: Lua output

    # echo "Original: [$1] Node: [$2] and so on" 

node --input-type "module" <<-EOF
import {log} from "console"
let results = {
    node:   "$2".split(","),
    ruby:   "$3".split(","),
    python: "$4".split(","),
    lua:    "$5".split(","),
}

let origNums = '$1'.split(",")
let langs = Object.keys(results)
let resultSizes = Object.entries(results).map(([lang, arr])=>[lang, arr.length])
    .reduce((p,[lang,size])=>({...p, [size]: [...(p[size]||[]), lang]}),{})

if(Object.keys(resultSizes).length > 1){
    log("Results mismatch (by length):")
    log(Object.entries(resultSizes)
    .reduce(
        (a, [size,langs]) => [...a, ...langs.map(lang=>[lang,size])], 
        []
    ).map(x=>x[0][0].toUpperCase() + x[0].slice(1) + ": " + x[1]).join("\n")) 
}
else {
    let size = Object.keys(resultSizes)[0]
    let diverge = false
    for(let i = 0; i < size; i++){
        let re = {}
        for(let [lang, arr] of Object.entries(results)){
            re[lang] = arr[i]
        }
        if((new Set(Object.values(re))).size > 1){
            diverge = true
            log("At " + i + ", result mismatch: ")
            log(Object.entries(re).map( ([lang,val]) => lang[0].toUpperCase() + lang.slice(1) + ": " + val).join("\n"))
            log("(Base number: " + origNums[i] + ")")
        }
    }
    if(!diverge) log("All results as expected.")
}
EOF
}
#endregion
#region Shellscript section: Test humanizing using random numbers
echo "== TEST 1: HUMANIZE =="
randnums=`node -p "Array.from(Array($num_amt)).map(_ => Math.trunc(Math.random()*1023 * (1024 ** (Math.random()*3)))).join(',')"`

nodenum=`node --input-type "module" <<-EOF
    import * as utils from "./utils.mjs"
    process.stdout.write([$randnums].map(v => utils.humanizeBytes(v)).join(",") )
EOF
`

rubynum=`ruby -r "$utils_path/utils.rb" <<-EOF
    print([$randnums].map{|v|humanize_bytes(v)}.join(","))
EOF
`

pythonnum=`python <<-EOF
from utils import humanize_bytes
print(",".join([humanize_bytes(v) for v in [$randnums]]))
EOF
`

luanum=`lua <<-EOF
dofile("$utils_path/utils.lua")
output={}
for _,v in pairs({$randnums}) do
    table.insert(output, humanize_bytes(v))
end
print(table.concat(output, ","))
EOF
`

check_outputs "$randnums" "$nodenum" "$rubynum" "$pythonnum" "$luanum"
#endregion
#region Shellscript section: Test dehumanizing using the previous output
echo "== TEST 2: DEHUMANIZE =="

humanized=$(node -p "JSON.stringify('$nodenum'.split(',')).slice(1,-1)")

nodenum=`node --input-type "module" <<-EOF
import * as utils from "./utils.mjs"
process.stdout.write([$humanized].map(v=>utils.dehumanizeBytes(v)||0).join(","))
EOF
`

rubynum=`ruby -r "$utils_path/utils.rb" <<-EOF
print([$humanized].map{|v|dehumanize_bytes(v)||0}.join(","))
EOF
`

pythonnum=`python <<-EOF
import math
from utils import dehumanize_bytes
print(",".join([str(dehumanize_bytes(v) or 0) for v in [$humanized]]))
EOF
`

luanum=`lua <<-EOF
dofile("$utils_path/utils.lua")
output={}
for _,v in pairs({$humanized}) do
    successful, dhb_or_error = pcall(dehumanize_bytes, v)
    if not successful then
        -- print(string.format("Number %s got error: %s", v, dhb_or_error))
        dhb_or_error = "0"
    end
    table.insert(output, tostring(dhb_or_error or "0"))
end
print(table.concat(output, ","))
EOF
`
check_outputs "$humanized" "$nodenum" "$rubynum" "$pythonnum" "$luanum"
#endregion