# What is eating the disk?
> Track: Files & filesystem · Level ★★☆ · ~8 min

## Statement
`data/` is too big. Find:
1. the **subdirectory of `data/`** using the most disk space
2. the **single file** under `data/` using the most disk space (actual blocks on disk, not apparent size)

Write `answer.txt` with exactly two lines: `dir=data/<name>` and `file=data/<path>`.

## Current state
- `data/` has 5 subdirectories with files of various sizes. One file *claims* to be 1 GB.

## Done when
`answer.txt` names the right directory and the right file.

## Hint
`du -sh data/*/ | sort -h` ranks directories. For files, `ls -lS` sorts by *apparent* size, which isn't what you want here.
Compare `ls -l` and `du -h` on `data/tmp/*`. `find -printf '%k %p\n'` prints the disk usage of each file in KiB.

## Key idea
`du` reports the blocks actually allocated and `ls -l` reports the size the file claims, so sparse files and open-but-deleted files (lab 19) are why `ls`, `du` and `df` disagree.

## Deep dive
- `df -h` shows usage per filesystem, `du` per file tree. `df -i` shows inode exhaustion ("disk full" with free space).
- `du -xh --max-depth=1 / | sort -h` is the classic way to find the culprit. `-x` stays on one filesystem.
- Sparse file: `truncate -s 1G f` has an apparent size of 1G but 0 blocks. `du --apparent-size` shows the ls-style number.
- `ncdu` is the interactive version if you're allowed to install things.
