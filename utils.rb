$PI=Math::PI
$TAU=$PI*2

def boolint(b) = 5-(!!b).to_s.size # Exclusively for Ruby (because there's no bool-to-int casting/hacking just like Python and JS).
def clear = STDOUT.write("\x1b[H\x1B[2J\x1b[3J")
def sleep(ms) = Kernel.sleep(ms/1000.0) # The pre-existing Kernel::sleep doesn't behave the same way than my JS's sleep() function.
def rand(n,x) = Kernel::rand()*(x-n)+n # The pre-existing Kernel::rand doesn't behave the same way than my JS's rand() function.
def irand(n,x) = rand(n,x).round
def choose(a) = a[irand(0,a.size-1)]
def humanize_bytes(bytes, si = false, digits = 1)
    basis = si ? 1000 : 1024
    
    scale = Math.log([1,bytes].max, basis).truncate
    raise RangeError.new("Number too large") if scale > 10
    coeff = bytes.to_f / (basis ** scale)
    unit = scale == 0 ? "B" : ("KMGTPEZYRQ"[scale-1] + (si ? "" : "i") + "B")

    return sprintf("%.#{scale == 0 ? 0 : digits}f #{unit}", coeff)
end
def dehumanize_bytes(humanText)
    matched = (/^(\d+) ?(B|[kKMGTPEZYRQ](?:iB|B?))?$/.match(humanText) || 
        /^(\d+\.\d+) ?([kKMGTPEZYRQ](?:iB|B?))$/.match(humanText))

    return nil if matched == nil

    coeff = matched.captures[0].to_f||0
    unit = matched.captures[1]
    scale = unit == nil ? 1 : ((unit.size>2) ? 1024 : 1000) ** (("KMGTPEZYRQ".index(unit[0].upcase)||-1)+1)

    return (scale * coeff).truncate
end
