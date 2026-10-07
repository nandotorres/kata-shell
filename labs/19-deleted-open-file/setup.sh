mkdir -p /var/log/kata
f=/var/log/kata/audit.log
rm -f "$KATA_RUN/19.pid"
setsid -f bash -c '
  exec 3>>"$1"
  head -c 50M /dev/zero >&3
  rm -f "$1"
  echo $$ > "$2"
  exec -a audit-daemon sleep infinity
' _ "$f" "$KATA_RUN/19.pid" >/dev/null 2>&1 < /dev/null
for _ in $(seq 50); do [[ -s $KATA_RUN/19.pid ]] && break; sleep 0.1; done
sleep 0.3
