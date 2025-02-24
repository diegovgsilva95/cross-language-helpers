import math
import re
import sys

PI = math.pi
TAU = PI * 2

def clear():
    sys.stdout.write("\x1b[H\x1b[2J\x1b[3J")

def humanize_bytes(bytes, si = False, digits = 1):
    basis = si and 1000 or 1024
    scale = math.trunc(math.log(max(1,bytes), basis))

    if scale > 10:
        raise ValueError("Number too large")
        
    coeff = bytes / (basis ** scale)
    unit = (scale == 0) and ("B") or ("KMGTPEZYRQ"[scale-1] + ["i",""][si] + "B")
    
    return f"%.{[digits,0][scale==0]}f {unit}" % coeff

def dehumanize_bytes(humanText):
    matched = re.match("^(\d+) ?(B|[kKMGTPEZYRQ](?:iB|B?))?$", humanText) or re.match("^(\d+\.\d+) ?([kKMGTPEZYRQ](?:iB|B?))$", humanText)
    
    if matched is None:
        return None

    (coeff, scale) = matched.groups()
    coeff = float(coeff) or 0.0
    scale = (scale is None) and 1 or ( ((len(scale)>2) and 1024 or 1000) ** ("KMGTPEZYRQ".find(scale[0].upper())+1) )

    return math.trunc(scale * coeff)
