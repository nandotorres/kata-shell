out=$(./report.sh does-not-exist.csv 2>/dev/null); rc=$?
assert "missing file: exits non-zero (got $rc)" test "$rc" -ne 0
refute "missing file: does not print REPORT OK" grep -q 'REPORT OK' <<< "$out"

out=$(./report.sh orders.csv 2>&1); rc=$?
assert "valid file: exits 0 (got $rc)" test "$rc" -eq 0
compare_str "valid file: prints top 3 then REPORT OK" "$out" <<'EOF'
A104,4100
A101,1200
A103,980
REPORT OK
EOF
