# Log it, watch it, and count it in one pipeline
> Track: Streams & pipes · Level ★★☆ · ~8 min

## Statement
Run `./build` **once**, in a **single pipeline**, so that:
- you still see the full output live on your terminal,
- the complete output (stdout **and** stderr) is saved to `build.log`,
- the number of lines containing `WARN` is written to `warn-count.txt`.

## Current state
- `./build` prints progress on stdout and some warnings on **stderr**.

## Done when
`build.log` has every line `./build` printed (both streams, in order) and `warn-count.txt` has the right count.

## Hint
`tee FILE...` writes its stdin to every FILE **and** to stdout, so it can sit in the middle of a pipe.
Streams: the pipe only carries stdout unless you merge with `2>&1` first. A terminal is a file too: try `/dev/tty` or `/dev/stderr`.

## Key idea
`tee` is a T-junction in a pipe: it copies stdin to files and to stdout at the same time, so you can save, watch and keep processing one stream.

## Deep dive
- `tee -a` appends instead of truncating.
- `echo 'line' | sudo tee -a /etc/hosts` is the standard way to write a root-owned file from a pipe, because `sudo echo x > /etc/hosts` fails: the redirect runs in *your* shell before sudo starts.
- `cmd | tee >(grep ERR > errors.log) | gzip > all.gz` fans out with process substitution, but the `>(…)` part runs asynchronously, so it may finish after the pipeline returns.
- cat vs tee: `cat` reads files and writes stdout, `tee` reads stdin and writes stdout **plus** files.
