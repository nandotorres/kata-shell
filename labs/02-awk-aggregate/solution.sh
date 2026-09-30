awk '{ sum[$9] += $10 } END { for (code in sum) print code, sum[code] }' logs/access.log | sort -n > bytes-by-status.txt
