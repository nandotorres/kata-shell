# Edit a config file in place with sed
> Track: Text processing · Level ★★☆ · ~8 min

## Statement
Patch `app.conf` **in place** (no editor, scriptable, so it could run on 200 servers):
1. change `port=80` to `port=8080`
2. enable debug: `#debug=true` becomes `debug=true`
3. delete every line whose key starts with `legacy_`
4. keep the untouched original as `app.conf.bak`

## Current state
- `app.conf`: 9 lines of `key=value` plus a comment. There's also an `upstream_port=8000` line.

## Done when
`app.conf` has the 3 changes and nothing else changed; `app.conf.bak` is byte-identical to the original.

## Hint
`sed -i.bak -e 'cmd1' -e 'cmd2' file` edits in place and keeps a backup.
Anchor your patterns with `^` and `$`. What does a naive `s/80/8080/` do to `upstream_port=8000`?

## Key idea
sed applies `address + command` to each line (`s` substitutes, `d` deletes), `-i` rewrites the file in place, and anchors stop you from matching more than you meant.

## Deep dive
- Address forms: `/regex/`, line number `3`, range `/start/,/end/`, negation `/re/!d`.
- `sed -n '/re/p'` behaves like grep. `sed -E` enables `+ ? | ()` without backslashes.
- GNU vs BSD: macOS needs `sed -i ''`. Interviewers love that one.
- For changing a value whatever it currently is: `sed -i 's/^\(port=\).*/\18080/' app.conf`.
