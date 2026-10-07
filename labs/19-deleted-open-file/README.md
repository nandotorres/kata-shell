# Disk full, but du can't find it
> Track: Processes & signals · Level ★★★ · ~12 min

## Statement
`df` shows space disappearing on `/var/log`, but `du -sh /var/log` looks tiny. Someone `rm`'d a huge log while a
daemon still had it open. Without **stopping or restarting** the daemon:
1. find the process and the file descriptor holding the deleted file, and write `PID FD` (e.g. `1234 3`) to `answer.txt`
2. free the space

## Current state
- A process named `audit-daemon` holds a ~50 MB file that was deleted from `/var/log/kata/`.

## Done when
`answer.txt` is right, the daemon is still running, and the deleted file is now 0 bytes.

## Hint
`lsof +L1` lists open files with a link count below 1 (deleted but still open). Without lsof: `ls -l /proc/*/fd 2>/dev/null | grep deleted`.
`/proc/PID/fd/N` is a live handle to the file, so you can truncate through it.

## Key idea
Deleting a file only removes its name: the data stays until the last open file descriptor closes, so you find it with `lsof +L1` and truncate it through `/proc/PID/fd/N` (or restart the process).

## Deep dive
- `: > /proc/PID/fd/N` truncates in place. Plain `> file` would only work if the name still existed.
- This is why log rotation uses `copytruncate` or signals the daemon (`kill -HUP`) to reopen its log.
- Recover a deleted file: `cp /proc/PID/fd/N /tmp/rescued.log`. The data is still there.
- Inodes: a name is just a directory entry pointing to an inode, and hard links are extra names. `ls -i` and `stat` show the inode and link count.
