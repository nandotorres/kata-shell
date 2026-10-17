# Write a backup script you can trust
> Track: Scripting · Level ★★★ · ~20 min

## Statement
Write `backup.sh SRC DEST_DIR` so it behaves like a real Unix tool.
- Wrong number of arguments: print `usage: backup.sh SRC DEST_DIR` to **stderr** and exit **2**.
- `SRC` is not a directory: print an error to **stderr**, exit **1**, create nothing.
- Otherwise: create `DEST_DIR` if needed and write `DEST_DIR/<basename of SRC>-<YYYYMMDD>.tar.gz` containing the
  directory (archive paths start with `<basename>/`, not an absolute path), then print **only the archive path** on stdout and exit 0.
- Must work with spaces in every path.
- Must pass `shellcheck -S warning`.

## Current state
- `backup.sh` is a naive first draft: unquoted variables, no validation, wrong exit codes.

## Done when
The checker's scenarios (no args, too many args, missing source, paths with spaces, archive contents, shellcheck) all pass.

## Hint
Order: validate args, then validate inputs, then do the work. `(( $# == 2 )) || { echo "usage: …" >&2; exit 2; }`.
`tar -C "$(dirname "$src")" -czf "$out" "$(basename "$src")"` keeps archive paths relative. Quote **everything**.

## Key idea
A robust script validates its inputs first, quotes every expansion, reports errors on stderr with distinct exit codes, and prints only its result on stdout so it composes in pipelines.

## Deep dive
- `set -euo pipefail` is the baseline, not a substitute for explicit checks.
- `"$@"` forwards args intact, while `$*` and unquoted `$@` re-split them.
- `--` ends option parsing: `rm -- "$f"` is safe even if `$f` is `-rf`.
- `readonly`, `local`, and `main "$@"` at the bottom make longer scripts testable.
- `getopts` handles `-v -o file` style flags when a script needs them.
- `shellcheck` catches most quoting bugs before the script runs anywhere else.
