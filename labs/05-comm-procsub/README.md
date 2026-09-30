# Who never badged in? (set operations on files)
> Track: Text processing · Level ★★☆ · ~8 min

## Statement
Security asks two questions:
1. Which employees in `employees.txt` have **never** swiped a badge? Write them to `never-badged.txt`.
2. Which names in `badge-swipes.log` are **not** employees? Write them to `unknown-badges.txt`.

Both files must be sorted and contain one name per line with no duplicates. Try to do each in **one command without temp files**.

## Current state
- `employees.txt`: one name per line, unsorted.
- `badge-swipes.log`: `TIMESTAMP NAME DOOR`, unsorted, with many repeats.

## Done when
Both files contain exactly the right sets of names.

## Hint
`comm` compares two **sorted** files and prints 3 columns: only-in-1, only-in-2, in-both. `-23` keeps only column 1.
`<(command)` lets you pass a command's output where a filename is expected.

## Key idea
`<(cmd)` turns a command's output into a temporary file path (`/dev/fd/63`), so file-oriented tools like `comm` and `diff` can consume pipelines directly.

## Deep dive
- Set ops cheat sheet with sorted, unique inputs: A∖B = `comm -23 A B`, B∖A = `comm -13 A B`, A∩B = `comm -12 A B`, A∪B = `sort -u A B`.
- Without sorting, `comm` gives wrong answers; GNU `comm` warns "file 1 is not in sorted order".
- Alternative with no sorting: `grep -vxFf <(awk '{print $2}' badge-swipes.log) employees.txt`, where `-F` means fixed strings, `-x` whole line, `-f` patterns from a file.
- `echo <(true)` prints the `/dev/fd/N` path, which shows what the shell substituted.
