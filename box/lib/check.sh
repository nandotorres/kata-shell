# shellcheck shell=bash
# Assertion helpers sourced before every labs/*/check.sh.
# Expected values come from stdin (heredocs) so check files read like "this is the answer".

_fails=0
_ok() { printf '  \033[32m✔\033[0m %s\n' "$*"; }
_ko() { printf '  \033[31m✘\033[0m %s\n' "$*"; _fails=$((_fails + 1)); }

# assert "description" command [args...]
assert() {
  local d=$1; shift
  if "$@" >/dev/null 2>&1; then _ok "$d"; else _ko "$d"; return 1; fi
}

# refute "description" command [args...]   (passes when the command fails)
refute() {
  local d=$1; shift
  if "$@" >/dev/null 2>&1; then _ko "$d"; return 1; else _ok "$d"; fi
}

_diff() { # expected_file actual_file
  printf '      \033[2m--- expected   +++ yours\033[0m\n'
  diff -u "$1" "$2" | tail -n +3 | head -n 40 | sed 's/^/      /'
}

# compare "description" FILE   <<< expected content
compare() {
  local d=$1 f=$2 exp
  exp=$(mktemp)
  cat > "$exp"
  if [[ ! -f $f ]]; then _ko "$d ($f does not exist yet)"
  elif cmp -s "$exp" "$f"; then _ok "$d"
  else _ko "$d"; _diff "$exp" "$f"; fi
  rm -f "$exp"
}

# compare_str "description" "$actual"   <<< expected content
compare_str() {
  local d=$1 act
  act=$(mktemp)
  printf '%s\n' "$2" > "$act"
  compare "$d" "$act"
  rm -f "$act"
}

# wait_for SECONDS command...   (polls every 0.2s)
wait_for() {
  local deadline=$((SECONDS + $1)); shift
  until "$@" >/dev/null 2>&1; do
    (( SECONDS >= deadline )) && return 1
    sleep 0.2
  done
}

finish() { (( _fails == 0 )); }
