# Fix permissions on a project tree
> Track: Files & filesystem · Level ★★☆ · ~10 min

## Statement
An auditor flagged `project/`: everything is world-writable. Set exactly:
- every directory: `755`, **except** `project/shared`, which must be a world-writable drop box where users can't delete each other's files (like `/tmp`)
- every regular file: `644`, except
  - `project/secret.key`: readable and writable by the owner only
  - `project/bin/run.sh`: executable by everyone, writable only by the owner

## Current state
- Everything under `project/` is `777` or `666` (`find project -printf '%m %p\n'`).

## Done when
`find project -printf '%p %m\n'` matches the expected modes exactly.

## Hint
Octal digits are user/group/other with r=4, w=2, x=1. `find project -type d -exec chmod 755 {} +` handles all dirs at once.
The "can't delete others' files" behavior is the **sticky bit**, a leading `1`.

## Key idea
Mode bits are three octal digits for user/group/other (r=4 w=2 x=1). On a directory, `x` means "may enter", and the sticky bit (`1777`, like `/tmp`) means only a file's owner can delete it.

## Deep dive
- `stat -c '%A %a %U:%G %n' file` shows symbolic mode, octal mode and owner.
- Symbolic form: `chmod u+x,go-w file`. `chmod -R 644 dir` is a classic mistake because it removes `x` from directories and locks everyone out.
- `umask 022` is why new files are created 644 and dirs 755.
- setuid (`4xxx`) runs a program as its owner, which is how `passwd` works. setgid on a dir (`2xxx`) makes new files inherit the group.
- Find risky files: `find / -xdev -type f -perm -o+w` (world-writable), `find / -perm -4000` (setuid).
