compare "build.log has every line from both streams, in order" build.log <<'EOF'
[1/6] resolving dependencies
WARN: package left-pad is deprecated
[2/6] compiling core
[3/6] compiling plugins
WARN: plugin 'legacy' has no tests
[4/6] linking
note: warnings are not errors (yet)
[5/6] running unit tests: 142 passed
WARN: 3 tests skipped
[6/6] packaging build-1.4.2.tar.gz
WARN: artifact not signed
BUILD SUCCESS
EOF
compare_str "warn-count.txt counts WARN lines from both streams" "$(tr -d '[:space:]' < warn-count.txt 2>/dev/null)" <<'EOF'
4
EOF
