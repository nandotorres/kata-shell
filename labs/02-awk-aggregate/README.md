# Bytes served per status code
> Track: Text processing · Level ★☆☆ · ~5 min

## Statement
Ops wants to know how much traffic each HTTP status code accounts for. From `logs/access.log`,
write `bytes-by-status.txt` with one line per status code: `STATUS TOTAL_BYTES`, sorted by status ascending.

## Current state
- `logs/access.log`: `IP - - [date tz] "GET /path HTTP/1.1" STATUS BYTES`. Status is field 9, bytes is field 10.

## Done when
`bytes-by-status.txt` looks like `200 123456` / `304 ...` / `404 ...` / `500 ...` with correct sums.

## Hint
awk has associative arrays: `sum[$9] += $10` on every line, then print them in an `END { for (k in sum) ... }` block.
`for (k in arr)` has no defined order, so sort afterwards.

## Key idea
awk is a loop over lines with fields `$1..$NF` and built-in hash maps, so it's the tool to reach for when you need to aggregate per key.

## Deep dive
- Count how many fields a line has: `awk '{print NF}'`. Check the field numbers before you trust them.
- Equivalent of `Object.entries(groupBy(...))`: `awk '{s[$9]+=$10; n[$9]++} END {for (k in s) printf "%s %d avg=%.1f\n", k, s[k], s[k]/n[k]}'`.
- `-F,` sets the field separator (CSV-ish), `-v x=1` passes shell values in. Never splice shell variables into the awk program text.
