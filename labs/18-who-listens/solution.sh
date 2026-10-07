ss -ltnp
pid=$(ss -Hltnp 'sport = :8081' | grep -o 'pid=[0-9]*' | head -n 1 | cut -d= -f2)
ps -p "$pid" -o pid,args
public=$(ss -Hltn | awk '$4 ~ /^0\.0\.0\.0:/ { sub(/.*:/, "", $4); print $4 }' | sort -n | paste -sd' ')
printf 'pid=%s\npublic_ports=%s\n' "$pid" "$public" > answer.txt
