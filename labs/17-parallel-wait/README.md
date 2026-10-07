# Run jobs in parallel and collect exit codes (Promise.all)
> Track: Processes & signals · Level ★★☆ · ~10 min

## Statement
`./job.sh N` takes 2 seconds. Run 5 of them sequentially and you wait 10s. Write `run-all.sh` that:
1. starts `./job.sh 1` … `./job.sh 5` **concurrently**,
2. waits for all of them and writes `results.txt` with one line per job **in order**: `job N: exit CODE`,
3. exits `1` if any job failed, `0` otherwise.

It must finish in well under 5 seconds.

## Current state
- `job.sh` exists. One of the jobs fails with a non-zero exit code.
- `run-all.sh` does not exist yet.

## Done when
`./run-all.sh` takes less than 5s, writes the correct `results.txt` and exits 1.

## Hint
`cmd &` starts a background job and `$!` is its PID right after. Store PIDs in an array, then loop and run `wait "$pid"`. Its exit status **is** the job's exit status.

## Key idea
`cmd &` starts a job, `$!` gives its PID, and `wait $pid` both blocks until it finishes and returns its exit status, which makes it Bash's `Promise.all`.

## Deep dive
- `wait` with no args waits for all jobs but returns 0, so you lose the individual statuses.
- `wait -n` returns as soon as **any** job finishes (`Promise.race`-ish), which is useful for a "max N in flight" pool.
- `xargs -P 4 -n 1 ./job.sh < ids.txt` runs a bounded worker pool in one line.
- `jobs -l` lists background jobs of the *interactive* shell. `fg`/`bg`/`Ctrl-Z` move them around.
- Zombies: a child that exited but hasn't been `wait`ed on. They cost a PID slot, not CPU.
