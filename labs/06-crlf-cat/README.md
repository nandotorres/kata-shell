# The script that "looks fine" (cat -A vs less vs more)
> Track: Text processing · Level ★★☆ · ~8 min

## Statement
A colleague committed `deploy.sh` from Windows. It looks perfect in `less`, yet `./deploy.sh` fails.
Make `./deploy.sh` run successfully **without retyping it**. Its job is to write `deployed.txt`.

## Current state
- `deploy.sh`: 3 lines that look correct.
- Running it fails. Read the error messages carefully, there's more than one problem.

## Done when
`deploy.sh` is executable, has Unix line endings, its visible content is unchanged, and running it creates `deployed.txt`.

## Hint
Use `cat -A deploy.sh` to show invisible characters: `^M` is a carriage return (`\r`), `$` marks end of line, `^I` is a tab.
`ls -l` shows the mode bits. `sed -i 's/\r$//'` strips the CRs.

## Key idea
`cat` dumps raw bytes to stdout (and `-A` makes the invisible ones visible), while `less`/`more` are pagers that render text for humans, so when something looks right but fails, check it with `cat -A`.

## Deep dive
- **cat**: concatenates files to stdout with no paging. Use it for small files or to feed a pipe. `cat -n` numbers lines, `-A` shows everything.
- **more**: old forward-only pager. Space for next page, q to quit.
- **less**: modern pager, scrolls both ways, `/search`, `n` next, `G` end, `F` follow (like `tail -f`), `-S` no wrap. Use it for reading big files.
- **tee**: not a viewer. It copies stdin to stdout *and* to files (see lab 13).
- `file deploy.sh` reports "with CRLF line terminators". `od -c` / `xxd` show raw bytes.
- The error `/usr/bin/env: 'bash\r': No such file or directory` happens because the kernel reads the shebang up to `\n`, so the interpreter name includes the `\r`.
