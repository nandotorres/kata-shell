expected=$(
  declare -A sum
  while read -r -a f; do sum[${f[8]}]=$(( ${sum[${f[8]}]:-0} + f[9] )); done < logs/access.log
  for k in "${!sum[@]}"; do printf '%s %s\n' "$k" "${sum[$k]}"; done | sort -n
)
compare "bytes-by-status.txt has 'STATUS TOTAL' per code, sorted" bytes-by-status.txt <<< "$expected"
