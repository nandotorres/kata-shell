compare "out.log has only stdout" out.log <<'EOF'
out: starting
out: processed 3 items
out: done
EOF
compare "err.log has only stderr" err.log <<'EOF'
err: config missing, using defaults
err: item 2 was slow
EOF
compare "all.log has both, in order" all.log <<'EOF'
out: starting
err: config missing, using defaults
out: processed 3 items
err: item 2 was slow
out: done
EOF
compare_str "status.txt has the exit code" "$(tr -d '[:space:]' < status.txt 2>/dev/null)" <<'EOF'
3
EOF
