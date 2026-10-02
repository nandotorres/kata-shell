# Clean up stale temp files, safely
> Track: Files & filesystem · Level ★★☆ · ~10 min

## Statement
Under `cache/`, delete every **regular file** whose name ends in `.tmp` (**any case**) and that was last modified
**more than 7 days ago**. Touch nothing else. Then write the **number of files deleted** to `deleted-count.txt`.

Careful: some filenames contain spaces, and one contains a **newline**.

## Current state
- `cache/` is a nested tree of `.tmp`, `.TMP`, `.log`, `.txt` files, some new and some weeks old (`ls -l --time-style=+%F -R cache`).

## Done when
Only the right files are gone, and `deleted-count.txt` holds the correct number.

## Hint
`find cache -type f -iname '*.tmp' -mtime +7` selects them. Run it with `-print` before adding `-delete`.
To count files safely you can't count *lines*, because one name contains a newline. Print one character per file instead (`-printf .`) and count characters.

## Key idea
`find` selects files by name, type, age and size, and `-delete`, `-exec … +` or `-print0 | xargs -0` are the only filename-safe ways to act on what it finds.

## Deep dive
- `-mtime +7` means "more than 7 full 24h periods ago", so effectively 8 days or more. `-mmin -30` means modified in the last 30 minutes.
- `find … | xargs rm` breaks on spaces. `find … -print0 | xargs -0 rm --` is safe. `-exec rm -- {} +` batches like xargs.
- `-delete` implies `-depth`. Always put it **last**: `find . -delete -name x` deletes everything.
- Dry run first: in interviews say "I'd run it with `-print` first".
