assert "backup.sh is executable" test -x backup.sh || return
script=$PWD/backup.sh
t=$(mktemp -d)
mkdir -p "$t/my docs/inner"
printf 'a\n' > "$t/my docs/a.txt"
printf 'b\n' > "$t/my docs/inner/b.txt"

run() { # captures stdout, stderr, rc
  out=$("$script" "$@" 2>"$t/err"); rc=$?; err=$(<"$t/err")
}

run
assert "no args: exit 2 (got $rc)" test "$rc" -eq 2
assert "no args: usage on stderr" grep -qi 'usage' <<< "$err"
assert "no args: nothing on stdout" test -z "$out"

run a b c
assert "3 args: exit 2 (got $rc)" test "$rc" -eq 2

run "$t/nope" "$t/out1"
assert "missing SRC: exit 1 (got $rc)" test "$rc" -eq 1
assert "missing SRC: error on stderr" test -n "$err"
assert "missing SRC: nothing on stdout" test -z "$out"
refute "missing SRC: no archive created" compgen -G "$t/out1/*.tar.gz"

expected="$t/backups here/my docs-$(date +%Y%m%d).tar.gz"
run "$t/my docs" "$t/backups here"
assert "valid run: exit 0 (got $rc)" test "$rc" -eq 0
compare_str "valid run: stdout is exactly the archive path" "$out" <<< "$expected"
assert "valid run: archive exists" test -f "$expected"
compare_str "valid run: archive paths are relative and complete" "$(tar -tzf "$expected" 2>&1 | grep -v '/$' | sort)" <<'EOF'
my docs/a.txt
my docs/inner/b.txt
EOF

assert "shellcheck -S warning is clean" shellcheck -S warning "$script"
rm -rf "$t"
