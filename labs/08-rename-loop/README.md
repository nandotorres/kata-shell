# Bulk rename files with spaces
> Track: Files & filesystem · Level ★☆☆ · ~8 min

## Statement
In `photos/`, every file ending in uppercase `.JPG` must be renamed so that the extension becomes `.jpg`
**and** spaces in the name become underscores (`IMG 0001.JPG` → `IMG_0001.jpg`).
Other files must stay exactly as they are. File contents must be preserved.

## Current state
- `photos/` contains `.JPG`, `.jpg`, `.jpeg` and `.txt` files, several with spaces in their names.

## Done when
The directory listing matches the expected names and each renamed file still has its original content.

## Hint
`for f in *.JPG` is safe with spaces because globbing never word-splits. Build the new name with `${f// /_}` and `${f%.JPG}`.
Quote every use: `mv -- "$f" "$new"`.

## Key idea
Globs (`for f in *.JPG`) hand each filename over intact, and it's `$(ls)` plus unquoted `$f` that break on spaces, so always loop over globs and quote expansions.

## Deep dive
- `shopt -s nullglob` makes `*.JPG` expand to nothing when there's no match. Otherwise the loop runs once with the literal string `*.JPG`.
- `mv -n` refuses to overwrite and `mv -i` asks first, which protects you when two names collapse to the same target.
- `rename 's/ /_/g' *.JPG` (perl rename) exists but isn't installed everywhere. The loop works on every system.
- Recursive version: `find photos -name '*.JPG' -exec bash -c 'for f; do …; done' _ {} +`.
