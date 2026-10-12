# Query JSON from the shell with jq
> Track: Scripting · Level ★★☆ · ~10 min

## Statement
`services.json` is a status dump from a service registry. Produce:
1. `down.txt`: names of services whose status is **not** `up`, sorted, one per line
2. `by-region.tsv`: `REGION<TAB>COUNT` of services per region, sorted by region
3. `slowest.txt`: the name of the `up` service with the **highest** `latency_ms`

## Current state
- `services.json`: `{ "generated": …, "services": [ {name, region, status, latency_ms}, … ] }`. Some `latency_ms` values are `null`.

## Done when
The three files match.

## Hint
`.services[]` iterates the array, `select(.status != "up")` filters, `.name` projects, and `-r` prints raw strings without quotes.
`group_by(.region)` returns an array of arrays, `length` counts, and `@tsv` formats an array as a tab-separated line. `max_by(.latency_ms)` picks the max.

## Key idea
jq is awk for JSON: `.[]` iterates, `select()` filters, `-r` prints raw strings, and `@tsv`/`@csv` format rows, so never `grep` or `sed` JSON.

## Deep dive
- TypeScript mental model: `.services | map(select(.status == "up")) | max_by(.latency_ms) | .name`.
- Build JSON safely from shell variables: `jq -n --arg name "$n" --argjson port 80 '{name: $name, port: $port}'`. Never concatenate strings.
- `jq -e` sets the exit status from the result (`false`/`null` gives 1), which is handy in `if`.
- `curl -s api | jq '.items | length'` is the everyday combo.
- `// "default"` is jq's `??` operator.
