pid=$(cat "$KATA_RUN/19.pid")
compare "answer.txt has 'PID FD'" answer.txt <<< "$pid 3"
assert "audit-daemon is still running" kill -0 "$pid"
size=$(stat -L -c %s "/proc/$pid/fd/3" 2>/dev/null || echo "?")
assert "the deleted file was truncated to 0 bytes (now: $size bytes)" test "$size" = 0
