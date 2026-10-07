# A worker that shuts down gracefully
> Track: Processes & signals · Level ★★★ · ~15 min

## Statement
Turn `worker.sh` into a well-behaved long-running worker:
1. On start, create a temp file with `mktemp` and write its **path** to `worker.tmp-path`.
2. Loop forever (the stub already does).
3. On **SIGTERM** or **SIGINT**: append the line `graceful shutdown` to `worker.log` and exit with status **0**.
4. The temp file must be removed **whenever** the script exits, however it exits.

## Current state
- `worker.sh` is an infinite loop with no signal handling. `kill`ing it leaves junk behind.

## Done when
The checker starts `worker.sh` in the background, sends SIGTERM, and sees exit status 0, the log line, and the temp file gone.

## Hint
`trap cleanup EXIT` runs `cleanup` when the shell exits for any reason. `trap on_term TERM INT` runs `on_term` on those signals.
Call `exit 0` from the signal handler so the EXIT trap still runs.

## Key idea
`trap` runs your handler when a signal arrives (TERM, INT, HUP) or when the shell exits (EXIT), which makes it Bash's `finally` block. Nothing can trap SIGKILL.

## Deep dive
- Bash runs a trap only **after the current foreground command finishes**, so `sleep 300` delays shutdown by up to 300s. Use `sleep 300 & wait $!` so the signal interrupts `wait` immediately.
- `trap - TERM` restores the default action and `trap '' INT` ignores the signal.
- `trap 'echo "failed at line $LINENO" >&2' ERR` gives cheap stack-trace-like diagnostics with `set -E`.
- Containers: PID 1 gets no default signal handlers, which is why `docker stop` waits 10s and then SIGKILLs a shell script that doesn't trap TERM. Use `exec` or `tini`.
