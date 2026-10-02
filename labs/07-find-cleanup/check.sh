remaining=$(find cache -type f -print0 | sort -z | tr '\0' '\n')
compare_str "only fresh or non-.tmp files remain" "$remaining" <<'EOF'
cache/b.tmp
cache/deep/er/z.tmp.bak
cache/new.tmp
cache/notes.txt
cache/sub dir/keep.log
EOF
count=$(tr -d '[:space:]' < deleted-count.txt 2>/dev/null)
compare_str "deleted-count.txt holds the number of deleted files" "$count" <<'EOF'
5
EOF
