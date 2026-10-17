# Unix fundamentals

`kata docs <word>` prints only matching sections (e.g. `kata docs trap`, `kata docs systemd`, `kata docs tee`).
Each section ends with the lab that makes you practise it.

---

## Processes

- A **process** is a running program with a **PID**, a parent (**PPID**), a user, a cwd, environment variables and open file descriptors.
- New processes come from **fork** (copy the parent) followed by **exec** (replace the copy's program). Running `ls` in your shell means the shell forks, the child execs `/usr/bin/ls`, and the shell `wait`s for it.
- That's why `cd` must be a **builtin**: a child process can't change its parent's cwd. The same goes for `export`, `source`, `exit` and `read`.
- `/proc/PID/` exposes everything: `cmdline`, `environ`, `fd/`, `status`, `cwd`.
- **States** (`ps -o stat`): `R` running, `S` sleeping, `D` uninterruptible (stuck on I/O, even `kill -9` waits), `T` stopped, `Z` zombie.
- **Zombie**: the child exited but the parent never `wait`ed. It holds only a PID-table slot. Fix the parent, or kill it so PID 1 adopts and reaps the zombie.
- **Orphan**: the parent died first and init (PID 1) adopts the child. Daemons are deliberately orphaned (`setsid`, double fork).

```bash
ps -ef                         # everything, full format
ps -eo pid,ppid,stat,%cpu,%mem,etime,args --sort=-%cpu | head
pstree -p                      # tree with PIDs
pgrep -af nginx                # find by command line
top / htop                     # live; in top: P=cpu M=mem k=kill q=quit
```
Practice: lab 15, lab 19.

## Exit codes

- `0` means success and anything else is failure. `$?` holds the last command's status, so capture it immediately: `cmd; rc=$?`.
- Conventions: `1` general error, `2` usage error, `126` found but not executable, `127` command not found, `128+N` killed by signal N (`130` Ctrl-C, `137` SIGKILL / OOM killer, `143` SIGTERM).
- `if cmd` tests the exit code, not output. `[[ … ]]` and `(( … ))` are commands that return 0 or 1.
- `cmd1 && cmd2` runs cmd2 only if cmd1 succeeded. `cmd1 || cmd2` runs cmd2 only if cmd1 failed.

Practice: lab 11, lab 12, lab 23.

## Signals

| signal | # | default | typical use | catchable |
|---|---|---|---|---|
| HUP | 1 | terminate | terminal closed; daemons: reload config | yes |
| INT | 2 | terminate | Ctrl-C | yes |
| QUIT | 3 | core dump | Ctrl-\ | yes |
| KILL | 9 | terminate | last resort, no cleanup | **no** |
| TERM | 15 | terminate | polite stop (`kill` default, `systemctl stop`, `docker stop`) | yes |
| STOP | 19 | stop | pause (Ctrl-Z sends TSTP) | **no** |
| CONT | 18 | continue | resume | yes |
| CHLD | 17 | ignore | child changed state | yes |
| USR1/USR2 | 10/12 | terminate | app-defined (e.g. reopen logs) | yes |

```bash
kill PID            # TERM
kill -HUP PID       # reload
kill -0 PID         # exists? (sends nothing)
kill -9 PID         # only after TERM failed
pkill -f pattern ; killall name
```
Stop with TERM, wait a few seconds, then KILL. TERM lets the process flush buffers, remove PID/lock files and close connections.

Practice: lab 15, lab 16.

## trap

```bash
cleanup() { rm -rf -- "$tmpdir"; }
trap cleanup EXIT                         # always, like finally
trap 'echo "stopping"; exit 0' TERM INT   # graceful shutdown
trap 'echo "error on line $LINENO" >&2' ERR
trap '' HUP                               # ignore
trap - TERM                               # restore default
```
- Traps run **between** commands. While a foreground `sleep 60` is running, the TERM handler waits until it ends, so use `sleep 60 & wait $!`.
- Calling `exit` inside a signal handler still triggers the EXIT trap.
- SIGKILL and SIGSTOP can't be trapped. A power cut can't be trapped either, so make cleanup idempotent and handle stale files at startup.
- Container gotcha: a shell script as PID 1 ignores TERM unless it traps it, so `docker stop` waits 10s and then KILLs. Use `exec yourapp` or `--init`.

Practice: lab 16.

## File descriptors & redirection

Every process starts with **0 stdin**, **1 stdout**, **2 stderr**. Redirections rewire them *before* the command runs, **left to right**.

```bash
cmd > out.txt          # stdout to file (truncate)      1>out.txt
cmd >> out.txt         # append
cmd 2> err.txt         # stderr to file
cmd > all.txt 2>&1     # both: first 1→file, then 2→wherever 1 points (file)
cmd 2>&1 > out.txt     # WRONG for "both": 2→terminal (old 1), then 1→file
cmd &> all.txt         # bash shorthand for > all.txt 2>&1
cmd < in.txt           # stdin from file
cmd <<< "$string"      # here-string
cmd <<'EOF' … EOF      # here-doc
cmd > /dev/null 2>&1   # discard all
exec 3> log.txt; echo hi >&3; exec 3>&-   # open / use / close a custom fd
ls -l /proc/$$/fd      # see your shell's fds
```

Practice: lab 11, lab 13.

## Pipes

- `a | b` connects a's **stdout** to b's **stdin** through a kernel buffer (64 KiB on Linux). Both processes run **concurrently**. A pipe isn't a temp file.
- If `b` exits early (`| head -1`), `a` gets **SIGPIPE** on its next write and dies quietly. That's normal.
- **stderr does not go through the pipe** unless you merge it: `a 2>&1 | b` (or `a |& b`).
- The status of a pipeline is the **last** command's. `set -o pipefail` makes it fail if any stage fails. `${PIPESTATUS[@]}` gives every stage's status.
- Every stage runs in a **subshell**, so `… | while read x; do var=…; done` loses `var`.
- **Named pipe**: `mkfifo /tmp/p; producer > /tmp/p & consumer < /tmp/p`.
- **Process substitution**: `diff <(sort a) <(sort b)` turns a command into a `/dev/fd/N` path, and `tee >(gzip > x.gz)` does the same in the writing direction.

Practice: lab 01, lab 05, lab 12, lab 14.

## Subshells, builtins, sourcing, environment

```bash
( cd /tmp; x=1 )       # subshell: cwd and x don't leak out
{ cd /tmp; x=1; }      # group in the CURRENT shell (note the ; and spaces)
$(cmd)                 # command substitution = subshell, captures stdout
./script.sh            # new process: can't change your shell
source script.sh       # runs IN your shell (aka ". script.sh"), so cd/exports stick
export VAR=x           # copy into the environment of future children
VAR=x cmd              # only for that command
```
- Children inherit a **copy** of the environment. Nothing a child does can change the parent's variables.
- `type cmd` tells you whether something is an alias, function, builtin, or file on `$PATH`.

Practice: lab 14.

## Jobs: background, foreground, detaching

```bash
long_task &            # background; $! = its PID
jobs -l                # list jobs of this shell
fg %1 / bg %1          # bring to front / resume in background
Ctrl-Z                 # stop (SIGTSTP) the foreground job
wait "$pid"            # block, get its exit status
wait -n                # first job to finish
nohup cmd > out.log 2>&1 &   # survive terminal hangup (ignores HUP)
disown %1              # remove from job table (no HUP on exit)
setsid cmd             # new session, fully detached from the terminal
```
In production, don't `nohup` things: use a **systemd service** (lab 20) or `systemd-run --unit=x cmd`.

Practice: lab 17.

## cat vs more vs less vs tee (and friends)

| tool | reads | writes | interactive | use it for |
|---|---|---|---|---|
| `cat` | files (or stdin) | stdout | no | small files, joining files, feeding a pipe, `cat -A` to reveal hidden chars |
| `more` | file/stdin | terminal | yes, forward only | legacy pager, always present |
| `less` | file/stdin | terminal | yes, both ways, `/search`, `F` follow | reading anything longer than a screen. "less is more" |
| `tee` | stdin | stdout **and** files | no | saving a copy mid-pipeline, `sudo tee` to write root files |
| `head`/`tail` | file/stdin | stdout | no | first/last N lines. `tail -f` follows a growing log |

- "Useless use of cat": `cat f | grep x` is `grep x f`. The pipe starts a process that `grep` does not need.
- `cat` is *right* for concatenating (`cat a b > c`) and for `cat -A`/`cat -n`.
- `less +F file` follows like `tail -f` and Ctrl-C drops back to scrolling. `less -S` doesn't wrap long lines. `less -R` keeps colors.
- `sudo echo x > /root/f` fails because **your** shell opens the file before sudo runs, so use `echo x | sudo tee /root/f`.

Practice: lab 06, lab 13.

## Quoting & expansion order

Order the shell applies: brace `{a,b}`, then tilde `~`, then parameter `$x`, arithmetic `$(( ))` and command `$( )`, then **word splitting** (on IFS), then **globbing** (`*`), then quote removal.
Word splitting and globbing happen only on **unquoted** expansions, so quoting is what turns them off.

```bash
'single'     # completely literal
"double"     # expands $var $(cmd) $((math)), no splitting or globbing
$'ansi\t'    # C escapes: \n \t \x41
"$@"         # every arg, intact. "$*" = one string
```

Practice: lab 08, lab 23.

## Files, inodes, links, permissions

- A file is an **inode** (metadata + data blocks). A **name** is a directory entry pointing to it.
- **Hard link** (`ln a b`): a second name for the same inode. It can't cross filesystems or point to directories.
- **Symlink** (`ln -s target link`): a small file containing a path. It can dangle.
- `rm` removes a **name**. The data is freed when the link count reaches 0 **and** no process has it open (lab 19).
- **Permissions**: `rwx` for user/group/other, r=4 w=2 x=1. On directories, r = list, w = create/delete entries, x = enter/traverse.
- Special bits: setuid `4000` (run as owner, e.g. `passwd`), setgid `2000` (dirs: inherit group), sticky `1000` (dirs: only the owner deletes, e.g. `/tmp`).
- `umask 022` means new files are 644 and dirs 755.
- **du vs df**: `du` sums allocated blocks of names it can see, while `df` asks the filesystem. They disagree with deleted-but-open files, sparse files, or other mounts hiding data. `df -i` shows inode exhaustion.

Practice: lab 09, lab 10, lab 19.

## systemd

systemd is PID 1 on modern Ubuntu. It starts, supervises and logs **units**.

**Unit types**: `.service` (process), `.timer` (schedule), `.socket` (socket activation), `.target` (a group or sync point, like a runlevel), `.mount`, `.path`.

**Anatomy of a service** (`/etc/systemd/system/app.service`):
```ini
[Unit]
Description=My app
After=network-online.target      # ordering only
Wants=network-online.target      # weak dependency (Requires= is strong)

[Service]
Type=simple                      # simple | exec | forking | oneshot | notify
User=app
WorkingDirectory=/srv/app
Environment=PORT=8080
EnvironmentFile=-/etc/default/app
ExecStart=/srv/app/bin/server --port ${PORT}
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target       # what "enable" hooks into
```

**Everyday commands**:
```bash
systemctl status app                 # state, main PID, last log lines
systemctl start|stop|restart|reload app
systemctl enable --now app           # start at boot + now
systemctl disable app ; systemctl mask app   # mask = cannot be started at all
systemctl daemon-reload              # after editing unit files
systemctl edit app                   # drop-in override (preferred over editing the unit)
systemctl cat app                    # unit + drop-ins as systemd sees them
systemctl show app -p MainPID,Restart,Environment
systemctl list-units --failed
systemctl list-timers
journalctl -u app -e                 # jump to end of this unit's logs
journalctl -u app -f                 # follow
journalctl -u app --since "10 min ago" -p err
journalctl -b                        # this boot
systemd-analyze blame                # slow boot culprits
```

**Worth remembering**:
- `enable` ≠ `start`. `enable` creates a symlink in `<target>.wants/` and doesn't start anything without `--now`.
- `After=` is ordering only. `Requires=`/`Wants=` pull a dependency in, so you usually need both.
- `Restart=on-failure` restarts on non-zero exit, signal or timeout. `always` also restarts on a clean exit.
- Status `203/EXEC` means it couldn't exec (permissions, bad path, CRLF shebang).
- `ExecStart` isn't a shell: no pipes, `>`, `&&` or globs. Wrap it in `/bin/sh -c '…'` if you must.
- Timers vs cron: timers log to the journal, can catch up (`Persistent=true`), have dependencies, and show their next run in `list-timers`.
- Stopping sends SIGTERM, then SIGKILL after `TimeoutStopSec` (90s default) to the whole cgroup, so stray child processes are cleaned up too.

Practice: lab 20, lab 21, lab 22.

---

## How it actually works

**What happens when you type `ls -l | grep foo` and press Enter?**
The shell parses the line, creates a pipe, forks twice, and wires child 1's stdout to the pipe's write end and child 2's stdin to the read end. Each child execs its program (found via `$PATH`), and the shell waits for both and sets `$?` from the last one.

**Difference between `$*` and `$@`?**
Quoted, `"$@"` keeps each argument separate while `"$*"` joins them into one string. Unquoted, both split again.

**How do you find which process uses port 443?**
`ss -ltnp 'sport = :443'`, or `lsof -iTCP:443 -sTCP:LISTEN`.

**Disk is full, what do you do?**
`df -h` (which filesystem?), `df -i` (inodes?), `du -xh --max-depth=1 / | sort -h` (where?), then `lsof +L1` (deleted but open?). After that, clean up or rotate logs safely.

**How do you make a script safe?**
`set -euo pipefail`, quote everything, validate inputs early, `mktemp` + `trap … EXIT`, errors to stderr with meaningful exit codes, and `shellcheck`.

**`kill` vs `kill -9`?**
TERM can be handled, so the process can clean up. KILL is handled by the kernel immediately with no cleanup, so use it last.

**How do you run something every 5 minutes?**
cron (`*/5 * * * * cmd`) or a systemd timer (`OnCalendar=*:0/5`). Mention logging and overlap protection (`flock -n /tmp/x.lock cmd`).

**Why does `cd` in a script not change my shell's directory?**
The script runs in a child process. Use `source script.sh` instead.

**Hard link vs symlink?**
A hard link is another name for the same inode. A symlink is a separate file containing a path.

**What's a zombie, and how do you get rid of it?**
A process that exited but wasn't `wait`ed on. Fix or restart the parent, and then PID 1 reaps it. You can't kill a zombie because it's already dead.

**What does `2>&1` mean?**
Make fd 2 a copy of fd 1 at that point in the redirection list.

**How do you read a file line by line correctly?**
`while IFS= read -r line || [[ -n $line ]]; do …; done < file`

**How do you process filenames with spaces or newlines?**
`find … -print0 | xargs -0 …` or `find … -exec … {} +`, and globs with quoted `"$f"`.

**`>` vs `>>` vs `tee` vs `tee -a`?**
Truncate vs append, and `tee` additionally passes the data through to stdout.

**`source` vs `./script` vs `bash script`?**
`source` runs in your current shell. The other two start a child process, and `./` needs the exec bit and a shebang.
