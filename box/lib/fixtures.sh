# shellcheck shell=bash
# Deterministic fixture generators shared by lab setup scripts.

# gen_access_log FILE — nginx-style log; per-IP counts are fixed, order is shuffled.
gen_access_log() {
  awk 'BEGIN {
    srand(42)
    n = split("10.0.0.5:42 192.168.1.20:31 10.0.0.9:17 172.16.0.3:9 10.0.0.7:5 8.8.4.4:2 203.0.113.50:1", spec, " ")
    split("/ /login /api/items /api/items/7 /static/app.js /health", paths, " ")
    split("200 200 200 200 304 404 500", codes, " ")
    for (i = 1; i <= n; i++) {
      split(spec[i], kv, ":")
      for (j = 0; j < kv[2]; j++)
        printf "%.8f %s %s %s %d\n", rand(), kv[1], paths[1 + int(rand() * 6)], codes[1 + int(rand() * 7)], 200 + int(rand() * 5000)
    }
  }' | sort -n | awk '{
    t = NR * 23
    printf "%s - - [16/Oct/2026:09:%02d:%02d +0000] \"GET %s HTTP/1.1\" %s %d\n", $2, int(t / 60) % 60, t % 60, $3, $4, $5
  }' > "$1"
}
