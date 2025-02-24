#!/bin/sh

# Usage: tests/list-utils.sh
# (i.e., at the project's root folder)

utils_path="$(realpath $(dirname $0))/.."

echo "== List of methods and global variables =="

node --input-type "module" <<EOF
import * as utils from "./utils.mjs"
console.log("Javascript:")
// Seems like JS already do sorting for object keys but, just to guarantee...
let sortedUtils = Object.keys(utils).sort() 

for(let funOrConst of sortedUtils)
    console.log("\t" + funOrConst + ": " + typeof utils[funOrConst])
EOF

python <<EOF
import utils
print("Python:")
sorted_utils = sorted(dir(utils))

for fun_or_const in sorted_utils:
    if not fun_or_const.startswith("__"):
        print("\t" + fun_or_const + ": " + type(getattr(utils, fun_or_const)).__name__)
EOF

# Note: for Ruby, some of my definitions are "overwriting" global definitions 
#  (such as sleep and rand), so they won't be listed.

ruby <<EOF
initial_methods = private_methods
initial_variables = global_variables

require "$utils_path/utils"

utils = (private_methods - initial_methods) + (global_variables - initial_variables)
sorted_utils = utils.sort

print "Ruby: \n"
sorted_utils.each{|fun_or_const|
    fun_or_const_type = eval("defined?(%s)" % fun_or_const)
    fun_or_const_type = eval("%s.class.name" % fun_or_const) if(fun_or_const_type == "global-variable") 
    print "\t" + fun_or_const.to_s + ": " + fun_or_const_type + "\n"
}
EOF


lua <<EOF
    initial_global = {}
    new_global = {}
    fun_or_const_type = ""
    for k in pairs(_G) do initial_global[k] = true end
    print("Lua:")

    dofile("$utils_path/utils.lua")

    -- I won't sort for Lua, because I'm using _G (and global is already messed for Lua)

    for k in pairs(_G) do 
        if not initial_global[k] then
            fun_or_const_type = type(_G[k])
            print("\t" .. k .. ": " .. fun_or_const_type)
        end
    end
EOF
