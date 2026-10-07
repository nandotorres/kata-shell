# Find and stop the CPU hog, politely
> Track: Processes & signals · Level ★★☆ · ~8 min

## Statement
The box feels slow. Three background workers are running, and one of them is burning a full CPU core.
1. Write the hog's **PID** to `hog.pid`.
2. Stop it **gracefully**, so it gets the chance to clean up. Don't use `kill -9`.
3. Leave the other workers running.

## Current state
- Three workers (`report-builder`, `cache-warmer`, `mail-relay`) were started by the lab, detached from your shell.
- Which one is the hog changes every time you `kata reset`.

## Done when
`hog.pid` has the right PID, the hog has exited **via SIGTERM** (it logs that it shut down cleanly), and the other two are still alive.

## Hint
`ps -eo pid,ppid,%cpu,etime,args --sort=-%cpu | head` or `top` (press `P` to sort by CPU, `q` to quit).
`kill PID` sends SIGTERM by default.

## Key idea
`ps … --sort=-%cpu` (or `top`) finds the culprit, and `kill` sends SIGTERM, a catchable "please exit" signal, while `kill -9` (SIGKILL) can't be caught and skips all cleanup, so it's the last resort.

## Deep dive
- `pgrep -af NAME` finds PIDs by command line. `pkill NAME` signals them. `pidof prog` matches the exact program name.
- `kill -l` lists signals: HUP=1 (reload config), INT=2 (Ctrl-C), KILL=9, TERM=15, STOP=19 (pause), CONT=18 (resume).
- `kill -0 PID` sends nothing and just tests whether the process exists and you're allowed to signal it.
- `ps -o stat`: R running, S sleeping, D uninterruptible I/O (even SIGKILL waits), Z zombie (exited, parent hasn't `wait`ed), T stopped.
- `renice +10 PID` lowers priority instead of killing, which is a good answer when the process is legitimate.
