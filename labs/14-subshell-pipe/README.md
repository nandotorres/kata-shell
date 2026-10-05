# The counter that always says 0
> Track: Streams & pipes · Level ★★☆ · ~10 min

## Statement
`./count.sh` should print how many servers in `servers.txt` are `up` and list their names. It always prints
`up: 0` and an empty list. Fix it so it reports correctly **for any `servers.txt`**.

## Current state
- `servers.txt`: `NAME STATE` per line. Look closely at the last line (`cat -A servers.txt`).
- `count.sh` loops with `cat servers.txt | while read …`.

## Done when
`./count.sh` prints the correct count and names, including the server on the last line.

## Hint
Two bugs. (1) Each side of `|` runs in its own subshell, so variables set inside the loop disappear when it ends.
(2) `read` returns non-zero on a final line with no trailing newline, so the loop body never sees that line.

## Key idea
Each side of a pipe runs in a subshell, so variables set inside `… | while read` vanish. Feed the loop with `< file` or `< <(cmd)` so it runs in your shell.

## Deep dive
- `while IFS= read -r line || [[ -n $line ]]; do … done < file` is the idiom for reading every line, including an unterminated last one.
- `IFS=` keeps leading/trailing whitespace and `-r` keeps backslashes.
- `shopt -s lastpipe` (non-interactive Bash) runs the last pipe stage in the current shell. It works, but it's less portable.
- The same trap: `echo hi | read x; echo "$x"` prints nothing. Use `read x <<< "hi"`.
- `( … )` is an explicit subshell and `{ …; }` is a group in the current shell. `cd` inside `( )` doesn't leak out.
