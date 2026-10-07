assert "run-all.sh exists and is executable" test -x run-all.sh || return
rm -f results.txt
start=$(date +%s%N)
./run-all.sh >/dev/null 2>&1; rc=$?
ms=$(( ($(date +%s%N) - start) / 1000000 ))
assert "finishes in under 5s (took ${ms}ms)" test "$ms" -lt 5000
assert "exits 1 because a job failed (got $rc)" test "$rc" -eq 1
compare "results.txt lists each job's exit code in order" results.txt <<'EOF'
job 1: exit 0
job 2: exit 0
job 3: exit 7
job 4: exit 0
job 5: exit 0
EOF
