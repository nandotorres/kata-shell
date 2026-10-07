rm -f worker.log worker.tmp-path
./worker.sh & pid=$!
if ! wait_for 3 test -s worker.tmp-path; then
  _ko "worker.sh writes its temp file path to worker.tmp-path"
  kill -KILL "$pid" 2>/dev/null; wait "$pid" 2>/dev/null
  return
fi
_ok "worker.sh writes its temp file path to worker.tmp-path"
tmp=$(<worker.tmp-path)
assert "the temp file exists while running ($tmp)" test -f "$tmp"

kill -TERM "$pid"
if wait_for 5 bash -c "! kill -0 $pid"; then
  wait "$pid"; rc=$?
  assert "exits with status 0 on SIGTERM (got $rc)" test "$rc" -eq 0
else
  _ko "exits within 5s of SIGTERM"
  kill -KILL "$pid" 2>/dev/null; wait "$pid" 2>/dev/null
fi
compare "worker.log has the shutdown line" worker.log <<'EOF'
graceful shutdown
EOF
refute "the temp file was removed" test -e "$tmp"
