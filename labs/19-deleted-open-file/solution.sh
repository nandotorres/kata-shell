lsof -nP +L1
read -r pid fd < <(lsof -nP +L1 2>/dev/null | awk '/audit\.log/ { print $2, $4 + 0; exit }')
echo "$pid $fd" > answer.txt
: > "/proc/$pid/fd/$fd"
