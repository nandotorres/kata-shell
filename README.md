# shell-kata

## Quick start

![Read the statement, fail the check, take the hint, fix it, pass, and move on](docs/quickstart.gif)

The loop, about 20 seconds: read the statement, try an answer, `kata check` (it fails), `kata hint`, fix it, `kata check` again, then `kata next`. The recording is [`docs/quickstart.cast`](docs/quickstart.cast); play it with `asciinema play docs/quickstart.cast`.

A local, Katacoda-style lab for the **Unix shell**: a real Ubuntu 24.04 box with **systemd as PID 1**,
24 hands-on labs with setup, teardown, live state, automatic checks with expected-vs-yours diffs, reference
solutions and a one-sentence key idea, plus a TypeScript → Bash cheat sheet and a fundamentals guide.

## Start

**Cursor / VS Code (recommended):** open this folder, run **"Dev Containers: Reopen in Container"**, then in the integrated terminal:

```bash
kata next
```

Your explorer shows your lab work dirs (`01-top-talkers/`, …), plus read-only `labs/` and `docs/`.
Markdown under `labs/` and `docs/` opens as a rendered preview.

**Any terminal (Docker only):**

```bash
./kata            # builds on first run (~1 min), boots, drops you into the box
```

Both use the same image and the same `shell-kata-work` volume, so progress carries over. Requires Docker Desktop or Docker Engine
(the container runs `--privileged` so systemd can manage cgroups; it's a disposable box, don't put secrets in it).

## The loop

```text
kata list                 # 24 labs in 6 tracks, with progress
kata start 7              # fresh setup + cd into ~/kata/07-find-cleanup
kata show                 # statement · current state · done-when
kata state                # what the files look like right now
kata hint
kata check                # ✔/✘ per criterion, unified diff (expected vs yours) on mismatch
kata solution [--apply]   # reference solution + key idea + deep dive
kata reset / kata stop    # back to the start state / tear down
kata cheat split          # TypeScript → Bash, only the matching section
kata docs trap            # fundamentals, only the matching section
kata read                 # whole lab sheet in a pager (glow)
```

From the host, `./kata <cmd>` forwards to the box (`./kata list`, `./kata check 3`).

## Labs

| Track | Labs |
|---|---|
| Text processing | 01 top talkers (`sort \| uniq -c`) · 02 awk group-by · 03 sed in place · 04 String.prototype in pure Bash · 05 `comm` + `<( )` · 06 CRLF, `cat -A` vs less/more |
| Files & filesystem | 07 `find -mtime -delete` with nasty names · 08 bulk rename · 09 permissions + sticky bit · 10 du vs ls (sparse files) |
| Streams & pipes | 11 stdout/stderr/exit codes · 12 `pipefail` · 13 `tee` · 14 pipe subshell + missing last newline |
| Processes & signals | 15 find + SIGTERM the CPU hog · 16 `trap` graceful shutdown · 17 parallel jobs + `wait` · 18 `ss -ltnp` · 19 deleted-but-open file |
| systemd | 20 write a service with restart-on-crash · 21 debug a failed unit via journal · 22 cron → timer |
| Scripting | 23 a backup script that fails safely (exit codes, quoting, shellcheck) · 24 jq |

Every lab is a folder: `README.md` (statement / current state / done when / hint / key idea / deep dive),
`setup.sh`, `check.sh`, `solution.sh`, and optionally `teardown.sh`. Checks run real behaviour: they `kill -9` your
service and expect systemd to restart it, send SIGTERM to your worker, run your script with an empty `PATH`, and so on.

## Trust, but verify

```bash
./kata selftest           # or: kata selftest 20 21
```

For every lab this sets up a fresh state, asserts the check **fails**, applies the reference solution, asserts the
check **passes**, and tears down. If you add a lab, it isn't done until selftest is green.

## Host commands

```text
./kata up | down | rebuild | wipe (delete work+progress) | nuke (container+volume+image) | selftest
```
