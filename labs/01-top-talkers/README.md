# Top talkers in an access log
> Track: Text processing · Level ★☆☆ · ~5 min

## Statement
Your web server is getting hammered. Find the **3 client IPs with the most requests** in `logs/access.log`
and write them to `top3.txt`, busiest first, formatted as `COUNT IP` (one space, no leading spaces).

## Current state
- `logs/access.log`: 107 nginx-style lines, client IP is the first field.
- `top3.txt` does not exist.

## Done when
`top3.txt` has exactly 3 lines like `42 10.0.0.5`.

## Hint
Extract field 1, then think SQL: `GROUP BY ip ORDER BY count DESC LIMIT 3`.
`uniq -c` only merges *adjacent* duplicates, and it left-pads the count with spaces.

## Key idea
`sort | uniq -c | sort -rn | head` is the shell's GROUP BY / ORDER BY / LIMIT, and you sort first because `uniq` only collapses adjacent duplicates.

## Deep dive
- `awk '{c[$1]++} END {for (ip in c) print c[ip], ip}' logs/access.log | sort -rn | head -3` does it in one pass with a hash map, which is better for huge files.
- `uniq -c` prints `     42 10.0.0.5`; the trailing `awk '{print $1, $2}'` re-joins the fields with a single space.
