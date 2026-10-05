# stdout, stderr and exit codes
> Track: Streams & pipes · Level ★☆☆ · ~8 min

## Statement
`./noisy` writes to both stdout and stderr and then exits with an error. Capture:
- `out.log`: **only** stdout
- `err.log`: **only** stderr
- `all.log`: **both**, interleaved in the order they were written
- `status.txt`: the program's exit code (just the number)

## Current state
- `./noisy` exists and is executable. Run it and see what happens.

## Done when
The four files match what the program actually produced.

## Hint
`>` redirects fd 1 and `2>` redirects fd 2. For "both into one file", the **order** of `>file` and `2>&1` matters.
`$?` holds the exit code of the *last* command only, so read it immediately.

## Key idea
`2>&1` means "point fd 2 wherever fd 1 points right now", so `>file 2>&1` sends both to the file while `2>&1 >file` leaves stderr on the terminal.

## Deep dive
- `&>file` is Bash shorthand for `>file 2>&1`. `|&` is shorthand for `2>&1 |`.
- `cmd 2>/dev/null` silences errors. `cmd >/dev/null 2>&1` silences everything.
- `exec 3>log; echo hi >&3` opens a custom fd for the rest of the script.
- Exit code conventions: 0 ok, 1 generic error, 2 usage error, 126 not executable, 127 command not found, 128+N killed by signal N (130 = Ctrl-C, 137 = SIGKILL, 143 = SIGTERM).
- `${PIPESTATUS[@]}` holds the exit codes of every stage of the last pipeline.
