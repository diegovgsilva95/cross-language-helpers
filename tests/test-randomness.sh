#!/bin/sh

utils_path="$(realpath $(dirname $0))/.."
range_from=4.2
range_to=11.9
range_amt=500


test_distribution(){
    # Param $1: Interpreter/language name
    # Param $2: output alternating between integer random and float random

node --input-type "module" <<-EOF
    import {log} from "console"
    log("Numeric randomness test for $1: ")
    let allNums = "$2".split(",").map(n=>parseFloat(n)||null)
    let floatNums = allNums.filter((_,i)=>(i&1)>0)
    let intNums = allNums.filter((_,i)=>(i&1)==0)

    log([
        "Min integer: " + Math.min(...intNums),
        "Max integer: " + Math.max(...intNums),
    ].join("\n"))
    log([
        "Min float..: " + Math.min(...floatNums),
        "Max float..: " + Math.max(...floatNums),
        "",
    ].join("\n"))
EOF
}


test_choices(){
    # Param $1: Interpreter/language name
    # Param $2: output alternating between integer random and float random
node --input-type "module" <<-EOF
    console.log("Unique options for $1: \t" + [...new Set("$2".split(","))].sort().join(", "))
EOF

}

echo "== TEST 1: irand and rand =="

nodenums=`
node --input-type "module" <<-EOF
import * as utils from "./utils.mjs"
process.stdout.write(Array.from(Array($range_amt)).map(
    (_,i) => i&1 ? utils.rand($range_from, $range_to) : utils.irand($range_from, $range_to)
).join(","))
EOF
`
test_distribution "Node" "$nodenums"

rubynums=`
ruby -r "$utils_path/utils.rb" <<-EOF
print(($range_amt).times.map{
    |i| i&1>0 ? rand($range_from, $range_to) : irand($range_from, $range_to)
}.join(","))
EOF
`
test_distribution "Ruby" "$rubynums"

pythonnums=`
python <<-EOF
from utils import rand, irand
print(",".join([str(rand($range_from, $range_to) if i&1>0 else irand($range_from, $range_to)) for i in range(0,$range_amt)]))
EOF
`
test_distribution "Python" "$pythonnums"

luanums=`
lua <<-EOF
dofile("$utils_path/utils.lua")
output={}
for i=1,$range_amt do -- notice: starting at 1...
    table.insert(output, tostring((i&1==0) and rand($range_from, $range_to) or irand($range_from, $range_to)))
end
print(table.concat(output, ","))
EOF
`
test_distribution "Lua" "$luanums"


echo "== TEST 2: Choose =="
choices=(red scarlet crimson)

nodechoices=`
node --input-type "module" <<-EOF
import * as utils from "./utils.mjs"
let choices = "${choices[@]}".split(" ")
process.stdout.write(
    Array.from(Array($range_amt)).map(
    (_,i) => utils.choose(choices)
    ).join(",")
)
EOF
`

rubychoices=`
ruby -r "$utils_path/utils.rb" <<-EOF
choices = "${choices[@]}".split(" ")
print(($range_amt).times.map{
    |i| choose(choices)
}.join(","))
EOF
`
pythonchoices=`
python <<-EOF
from utils import choose
choices = "${choices[@]}".split(" ")
print(",".join([choose(choices) for i in range(0,$range_amt)]))
EOF
`

luachoices=`
lua <<-EOF
dofile("$utils_path/utils.lua")
choices_str = "${choices[@]}"
choices={}
i = 0
last_i = 0
while true do
    i = choices_str:find(" ", i+1)
    if i == nil then break end
    table.insert(choices,choices_str:sub(last_i, i-1))
    last_i = i+1
end
table.insert(choices,choices_str:sub(last_i, #choices_str))

output={}
for i=1,$range_amt do
    table.insert(output, tostring(choose(choices)) )
end
print(table.concat(output, ","))
EOF
`

test_choices "Node" "$nodechoices"
test_choices "Ruby" "$rubychoices"
test_choices "Python" "$pythonchoices"
test_choices "Lua" "$luachoices"
