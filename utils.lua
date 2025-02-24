
-- In order to define a global:
PI = math.pi
TAU = PI * 2

function rand(n,x)
    return math.random() * (x-n) + n
end
function irand(n,x)
    -- no math.round or round, so... reinventing the wheel again!
    v = rand(n,x)
    if v % 1 <= 0.5 then
        v = math.floor(v)
    else
        v = math.ceil(v)
    end
    
    return v
end
function choose(a)
    return a[irand(1,#a)]
end
function humanize_bytes(bytes, si, digits)
    if type(si) ~= "boolean" then si = false end
    if type(digits) ~= "number" then digits = 1 end

    basis = si and 1000 or 1024
    scale = math.floor(math.log(math.max(1,bytes), basis))

    if scale > 10 then
        error("Number too large")
    end

    coeff = bytes / (basis ^ scale)
    unit = (scale == 0) and "B" or (("KMGTPEZYRQ"):sub(scale, scale) .. (si and "" or "i") .. "B")
    
    return string.format("%." .. ((scale == 0) and 0 or digits) .. "f ", coeff) .. unit
end

function dehumanize_bytes(humanText)
--[[
    JS/Ruby/Python would allow something like:
    matched = (/^(\d+) ?(B|[kKMGTPEZYRQ](?:iB|B?))?$/.match(humanText) || 
    /^(\d+\.\d+) ?([kKMGTPEZYRQ](?:iB|B?))$/.match(humanText))
    Lua's "regex" (pattern matching, as they call it), however, be damned (too weak).
    So I'm going to reinvent the wheel: a (very verbose) state-machine approach
]]

    unit = ""
    coeff = ""
    state = "coeff"
    errored = false

    for i=1,(#humanText) do
        ch = humanText:sub(i,i)
        if state == "coeff" then 
            if (type(tonumber(ch)) == "number") or ((ch == ".") and (#coeff > 0)) then
                coeff = coeff .. ch
            elseif (#coeff > 0) and (ch == " ") then
                -- do nothing, as it's optional space
            elseif (#coeff > 0) and (coeff:sub(#coeff, #coeff) ~= ".") and ("BkKMGTPEZYRQ"):find(ch) then
                if ch == "B" and coeff:find("%.") then
                    errored = 1
                    break
                end

                state = "unit"
                unit = ch
            else
                errored = 2
                break
            end
        elseif (state == "unit") then 
            if ((#unit == 1) and (ch == "i" or ch == "B")) or ((#unit == 2) and (unit:sub(2,2) == "i") and (ch == "B")) then
                unit = unit .. ch
            else
                errored = 3
                break
            end
        end
    end

    -- Double-check it...
    if (#unit > 3) then
        errored = 4
    elseif (#unit == 1) and ( unit:sub(1,1):find("[BkKMGTPEZYRQ]") == nil) then
        errored = 5
    elseif (#unit == 2) and (unit:sub(1,1):find("[kKMGTPEZYRQ]") == nil or unit:sub(2,2) ~= "B") then
        errored = 6
    elseif (#unit == 3) and (unit:sub(1,1):find("[kKMGTPEZYRQ]") == nil or unit:sub(2,2) ~= "i" or unit:sub(3,3) ~= "B") then
        errored = 7
    elseif (#coeff == 0) or (tonumber(coeff:sub(1,1)) == nil) or (tonumber(coeff:sub(#coeff,#coeff)) == nil) then
        errored = 8
    end

    if errored then 
        error(string.format("Invalid value '%s', last state '%s' coeff '%s' unit '%s' ch '%s', errored = '%s'\n", humanText, state, coeff, unit, ch, errored))
        return nil
    end

    -- Phew!

    coeff = tonumber(coeff) or 0
    
    if #unit == 0 then
        scale = 1
    else
        scale = ((#unit > 2) and 1024 or 1000) ^ ((("KMGTPEZYRQ"):find(unit:sub(1,1):upper())) or 0)
    end

    return math.floor(scale * coeff)
end
