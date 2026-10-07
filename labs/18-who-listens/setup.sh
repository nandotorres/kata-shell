listen() { # name addr port
  setsid -f bash -c 'echo $$ > "$1"; exec -a "$2" nc -lk "$3" "$4"' _ "$KATA_RUN/18.$1.pid" "$1" "$2" "$3" >/dev/null 2>&1 < /dev/null
}
listen metrics-agent 127.0.0.1 9100
listen api-gateway   0.0.0.0   8081
listen debug-shell   0.0.0.0   4444
for _ in $(seq 50); do
  [[ $(ss -Hltn | grep -cE ':(9100|8081|4444) ') -ge 3 ]] && break
  sleep 0.1
done
