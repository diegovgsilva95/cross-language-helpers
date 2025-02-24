## Summary
My main language is JS. I've been implementing and using several helper functions and global constants, which I often use across my projects and snippets (especially `sleep`, `irand` and `clear`).

However, I also develop using Python, Ruby and (less commonly) Lua.

With this project, I'm intending to achieve two goals:
- Having the same functions/constants I already have for JS, available across other scripting languages (for now, Python, Ruby and Lua, but I also intend to implement those functions for CLI PHP, Rlang, Perl and so on...)
- (Better) familiarizing myself with all those scripting languages in the process.

## Description for helper functions
I guess the current names hint at what each function does, but there's a brief list:
- `Singleton`: a class intended to be used as something like `class Foo extends Singleton`
- `choose`: a function that takes an array and outputs a random item from it
- `clear`: a function that uses an escape sequence to clear the terminal, including the scrollback 
- `dehumanizeBytes`: opposite/complementary of `humanizeBytes`. A function that takes a human-format byte unit number (e.g. "1.618 MiB") and outputs the absolute byte number (e.g. 1619595.968), supporting both SI-prefixes (KB,MB,GB,...) and binary units (KiB,MiB,GiB,...).
- `findInBuffer`: a function to find a buffer within a buffer, simple as that.
- `humanizeBytes`: opposite/complementary of `dehumanizeBytes`. A function that formats a number into byte units, optionally adhering to SI (KB,MB,GB,...) or binary (KiB, MiB, GiB) prefixes. The precision of digits for coefficient can also be specified as well.
- `irand`: a function that outputs an integer number between (or equal to) its first param and (or) second param.
- `mapNumber`: a function that maps a value (first param) from an initial range (second and third param) to a final range (fourth and fifth), optionally constraining it to the final range (sixth boolean) 
- `rand`: a function that outputs a float number between (or equal to) its first param and (or) second param.
- `sleep`: a function that sleeps so much miliseconds (first param)
- `weightedRandomChoose`: similar to `choose` but the input list has actually key-value pairs where the value is the key's weight (the bigger the value, the more the probability of choosing it)
- `pi`: Well, it's the π. The math π. No introduction needed, I guess.
- `tau`: It's double the π. It exists because things like `sin(2 * PI * frequency / N)` could be simply expressed as `sin(TAU * frequency / N)` (see? no need to multiply twice)
- `boolint` (Ruby only): JS, Python ~~and even Lua~~ (edit: Lua doesn't) allow for booleans to be casted to integers. Ruby doesn't. This function allows it for Ruby, (ab)using the fact that "true" has 4 characters and "false" has 5 (so `5-"false".size` is 0, `5-"true".size` is 1). The double-negation ensures a boolean.

## tests/
A folder for shell-script meta-utilities (i.e., to test current cross-language helper implementations). They need to be ran at the project's root (in other words, **don't** `cd tests/` to run them).

### tests/list-utils.sh
It hard-codedly iterates through currently-implemented helper files (utils.mjs, utils.py, utils.rb and utils.lua) and lists what they're currently exporting.

### tests/test-de-humanize-bytes.sh
A test tailored for `humanizeBytes` and `dehumanizeBytes`. It generates random numbers (using Node.js, storing it to a shellscript variable), feeds them to each `humanizeBytes` implementation, compares their output (also using Node.js), then proceeds to test each implementation of `dehumanizeBytes` (using Node.js's output as a basis) and compare their output (you guessed it: using Node.js). 

### tests/test-randomness.sh
A test tailored for `rand`, `irand` and `choose`. First, for each language/interpreter, generates both float and integer random numbers (reusing the same array by placing irand at even positions and rand at odd positions) within a given range, then compute their boundaries (min and max). Then, for each language/interpreter chooses multiple times among pre-defined items, then proceeds to determine their unique elements (it should reflect the original choices).

## Scripting languages (current and planned)
- [x] Javascript (Node.js)
- [ ] TypeScript
- [x] Python
- [x] Ruby
- [x] Lua
- [ ] PHP (`php` CLI)
- [ ] Perl?
- [ ] Shellscript? (as a language to implement each helper function)
- [ ] Microsoft PowerShell?
- [ ] R?
- [ ] Tk/Tcl?
- [ ] Julia?
- [ ] Pascal Script?
- [ ] VBScript? (Windows only, perhaps it'd work using Wine; just for nostalgia)
- [ ] AutoIt? (Windows only, perhaps it'd work using Wine)

_(...[and the list goes on...](https://en.wikipedia.org/wiki/Category:Scripting_languages))_

_(the items prefixed with "?" are very unlikely for the foreseeable future)_