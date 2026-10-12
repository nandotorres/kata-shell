jq -r '.services[] | select(.status != "up") | .name' services.json | sort > down.txt
jq -r '.services | group_by(.region)[] | [.[0].region, length] | @tsv' services.json > by-region.tsv
jq -r '[.services[] | select(.status == "up")] | max_by(.latency_ms) | .name' services.json > slowest.txt
