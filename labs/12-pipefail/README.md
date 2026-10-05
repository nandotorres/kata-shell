# A report that lies about success
> Track: Streams & pipes · Level ★★☆ · ~8 min

## Statement
`./report.sh FILE` prints the 3 biggest orders and then `REPORT OK`. A cron job runs it and only alerts on a non-zero exit.
Yesterday `orders.csv` was missing: the script printed `REPORT OK` and exited 0, so nobody got paged.

Fix `report.sh` so that when the input file is missing or unreadable it **exits non-zero and does not print `REPORT OK`**.
It must still work normally for a valid file.

## Current state
- `report.sh` uses `cat "$1" | sort … | head` and has no error handling.
- `orders.csv` is valid input (`id,amount`).

## Done when
`./report.sh missing.csv` exits non-zero without printing `REPORT OK`, and `./report.sh orders.csv` prints the top 3 and `REPORT OK` with exit 0.

## Hint
Run `./report.sh nope.csv; echo $?`. Which command's exit code does a pipeline return?
Look up `set -e`, `set -u` and `set -o pipefail`.

## Key idea
A pipeline's exit status is that of its **last** command, so without `set -o pipefail` a failure upstream of `| sort | head` is silently swallowed.

## Deep dive
- `set -euo pipefail`: `-e` exits on errors, `-u` makes unset variables an error, and `pipefail` fails the pipeline if any stage fails. It's the standard "strict mode" header.
- `set -e` caveats: it's ignored inside `if cmd`, `cmd || …`, `cmd && …`, and in functions called from those. Don't rely on it alone; check inputs explicitly too.
- `pipefail` gotcha: `producer | head -1` can fail with SIGPIPE (141) when `head` exits early and the producer is still writing.
- `"${PIPESTATUS[@]}"` shows every stage's status, e.g. `1 0 0`.
- Better still: validate explicitly, `[[ -r $1 ]] || { echo "cannot read $1" >&2; exit 1; }`.
