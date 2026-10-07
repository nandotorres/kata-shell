cat > run-all.sh <<'EOF'
#!/usr/bin/env bash
pids=()
for n in 1 2 3 4 5; do
  ./job.sh "$n" &
  pids[n]=$!
done

failed=0
: > results.txt
for n in 1 2 3 4 5; do
  wait "${pids[n]}"; rc=$?
  echo "job $n: exit $rc" >> results.txt
  (( rc == 0 )) || failed=1
done
exit "$failed"
EOF
chmod +x run-all.sh
