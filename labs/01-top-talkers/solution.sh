cut -d' ' -f1 logs/access.log | sort | uniq -c | sort -rn | head -n 3 | awk '{print $1, $2}' > top3.txt
