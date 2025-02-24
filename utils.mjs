import { stdout } from "process"

export const PI = Math.PI
export const TAU = PI*2

export const clear = () => stdout.write("\x1b[H\x1b[2J\x1b[3J")
export const sleep = ms => new Promise(r => setTimeout(r, ms))
export const rand = (n, x) => Math.random() * (x - n) + n
export const irand = (n, x) => Math.round(rand(n, x))
export const choose = a => a[irand(0, a.length-1)]
export const humanizeBytes = function(bytes, si = false, digits = 1){
    let basis = si ? 1000 : 1024

    let scale = (Math.log(Math.max(1,bytes)) / Math.log(basis))|0
    if(scale > 10) throw new RangeError("Number too large")

    let coeff = bytes / (basis ** scale)
    let unit = scale == 0 ? "B" : ("KMGTPEZYRQ"[scale-1] + (si ? "" : "i") + "B")

    // Sometimes, the rounding will diverge from the other languages
    // because JS does a different type of rounding
    // The divergence should not be too significant (.1) or frequent to bother

    return `${coeff.toFixed(scale == 0 ? 0 : digits)} ${unit}`
}
export const dehumanizeBytes = function(humanText){
    let matched = (humanText.match(/^(\d+) ?(B|[kKMGTPEZYRQ](?:iB|B?))?$/) 
      || humanText.match(/^(\d+\.\d+) ?([kKMGTPEZYRQ](?:iB|B?))$/))

    if(!matched)
      return null
    
    let [coeff, scale] = matched.slice(1, 3)
    coeff = parseFloat(coeff)||0
    scale = typeof scale === "undefined" ? 1 : (scale.length>2 ? 1024 : 1000) ** ("KMGTPEZYRQ".indexOf(scale[0].toUpperCase())+1)
    
    return Math.trunc(coeff * scale)
}

export class Singleton {
    static instance = null

    /**
     * @template T
     * @this {T}
     * @returns {InstanceType<T>}
    */
    static getInstance(){
        if(!this.instance)
            this.instance = new this()

        return this.instance
    }
}
export const findInBuffer = function(subbuf, buffer, bufAmt){
    let f = 0
    for(let i = Math.max(0, bufAmt - subbuf.length-1); i < bufAmt; i++)
        if(subbuf[f] == buffer[i]){
            if(++f == subbuf.length)
                return true
        } else 
            f = 0
    
    return false
}
async function waitUntilDatetime(timestamp, maxWait = 86400000) {
    let beginAt = Date.now()
    // Something scheduled should wait less than 24 hours, or 86400000 ms.
    // After that point, it'll take too damn long, even for a daemon, so it should be refused.

    if((timestamp - beginAt) > maxWait) // Refuse
        throw new Error(`Requested to wait for ${timestamp - beginAt} ms., which exceeds the limit of ${maxWait} ms.`)

    while(Date.now() < timestamp)
        await sleep(Math.min(timestamp - Date.now(), 10000))

    return (Date.now()-beginAt)
}
export const weightedRandomChoose = function(weightedChoices){
    let choiceKeys = Object.keys(weightedChoices)
    let cumulative = []
    let sum = 0

    if(choiceKeys.length == 0)
        return null

    for(let key of choiceKeys){
        sum += Math.abs(Number(weightedChoices[key])||1)
        cumulative.push(sum)
    }

    let randomPoint = Math.random()*sum
    let bsearchRange = [0, choiceKeys.length-1]

    while(bsearchRange[0] < bsearchRange[1]){
        let mid = Math.floor((bsearchRange[0]+bsearchRange[1])/2)
        if(randomPoint > cumulative[mid])
            bsearchRange[0] = mid+1
        else
            bsearchRange[1] = mid
    }
    return choiceKeys[bsearchRange[0]]
}

export function mapNumber(v, fn, fx, tn, tx, constrain = true){
    if(fx == fn) 
        return v < fn ? tn : tx

    v = (v - fn) / (fx - fn)
    
    if(constrain) 
        v = Math.min(1, Math.max(0, v))
        
    return ((v * (tx - tn)) + tn)
}
// There are many other helpers I coded (MIDI-related functions, color-related, etc). 
// I'll add them here as soon as I find them lurking inside my projects.