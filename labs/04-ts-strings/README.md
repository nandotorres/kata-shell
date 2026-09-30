# String.prototype in pure Bash
> Track: Text processing · Level ★★☆ · ~15 min

## Statement
You know `s.trim()`, `s.split(",")`, `s.indexOf(x)` in TypeScript. Implement them in `strings.sh` as Bash
functions using **only builtins and parameter expansion**: no `sed`, `tr`, `awk`, `cut` or other external commands.
The checker runs your functions with an empty `PATH`, so any external command fails.

| function | TypeScript | example |
|---|---|---|
| `trim S` | `s.trim()` | `trim "  hi there "` → `hi there` |
| `lower S` / `upper S` | `toLowerCase()` / `toUpperCase()` | `lower "HeLLo"` → `hello` |
| `replace_all S FROM TO` | `s.replaceAll(from, to)` | `replace_all a-b-c - +` → `a+b+c` |
| `starts_with S P` / `includes S P` | `startsWith` / `includes` | exit status 0 = true |
| `index_of S NEEDLE` | `s.indexOf(n)` | `index_of "hello world" "o w"` → `4`, missing → `-1` |
| `split S DELIM` | `s.split(d)` | one element per line, empty elements kept, multi-char delimiters OK |
| `pad_start S LEN CHAR` | `s.padStart(len, ch)` | `pad_start 7 3 0` → `007` |

Functions **print** their result to stdout without a trailing newline (except `split`, which prints one line per element).

## Current state
- `strings.sh` has stub functions that do nothing yet.

## Done when
Every test case in the checker matches. `kata check` shows a diff of expected vs actual outputs.

## Hint
`${s,,}` lowercases, `${s^^}` uppercases, `${s//from/to}` replaces all occurrences, `${s%%pattern*}` removes the longest matching suffix,
`${#s}` is the length. For `trim`, remove `${s%%[![:space:]]*}` (the leading whitespace) from the front. For `split`, loop
while `[[ $s == *"$d"* ]]` and peel off `${s%%"$d"*}`.
Quote the pattern part (`"$2"`) so `*` or `?` in user input are treated as literal characters, not globs.

## Key idea
Bash parameter expansion (`${s,,}` `${s//a/b}` `${s#prefix}` `${s%suffix}` `${s:i:n}` `${#s}`) gives you most of `String.prototype` without starting a single process.

## Deep dive
- Functions "return" strings by printing them; callers capture with `x=$(trim "$s")`. `return` is only for exit status 0–255.
- `IFS=, read -ra parts <<< "$s"` is the common split, but it **drops a trailing empty field** (`"a,b,"` gives 2 elements, JS gives 3) and only handles single-character delimiters.
- Inside `${s//"$from"/"$to"}`, the quotes make `$from` literal. Without them, `replace_all "a*b" "*" "-"` would glob-match.
- Performance: in a loop of 100k lines, `$(echo "$s" | tr ...)` starts 200k processes; parameter expansion starts none.
