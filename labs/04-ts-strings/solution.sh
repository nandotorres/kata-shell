cat > strings.sh <<'EOF'
# strings.sh — String.prototype for Bash, builtins only.

trim() {
  local s=$1
  s=${s#"${s%%[![:space:]]*}"}   # drop leading whitespace
  s=${s%"${s##*[![:space:]]}"}   # drop trailing whitespace
  printf '%s' "$s"
}

lower()       { printf '%s' "${1,,}"; }
upper()       { printf '%s' "${1^^}"; }
replace_all() { printf '%s' "${1//"$2"/"$3"}"; }
starts_with() { [[ $1 == "$2"* ]]; }
includes()    { [[ $1 == *"$2"* ]]; }

index_of() {
  local before=${1%%"$2"*}
  if [[ $before == "$1" && -n $2 ]]; then printf '%s' -1; else printf '%s' "${#before}"; fi
}

split() {
  local s=$1 d=$2
  while [[ $s == *"$d"* ]]; do
    printf '%s\n' "${s%%"$d"*}"
    s=${s#*"$d"}
  done
  printf '%s\n' "$s"
}

pad_start() {
  local s=$1 len=$2 ch=${3:- }
  while (( ${#s} < len )); do s=$ch$s; done
  printf '%s' "$s"
}
EOF
