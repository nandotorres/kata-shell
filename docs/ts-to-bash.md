# TypeScript → Bash cheat sheet

`kata cheat <word>` prints only the matching sections (e.g. `kata cheat split`, `kata cheat map`, `kata cheat try`).

Mental model: Bash variables are **strings**, functions **print** results and **return** a status (0–255), and
"methods" are either parameter expansions (no process started) or small programs connected by pipes.
Rule zero: **quote your expansions**: `"$var"`, `"${arr[@]}"`, `"$(cmd)"`.

---

## Strings

### length · s.length
```bash
s="hello"; echo "${#s}"                  # 5
```

### trim · s.trim() / trimStart() / trimEnd()
```bash
s=$'  \t hi there  '
s="${s#"${s%%[![:space:]]*}"}"           # trimStart
s="${s%"${s##*[![:space:]]}"}"           # trimEnd
# on a stream:  sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
# NOT xargs: it also eats quotes and backslashes
```

### toLowerCase · toUpperCase · capitalize
```bash
s="HeLLo"
echo "${s,,}"        # hello      (Bash 4+)
echo "${s^^}"        # HELLO
t=${s,,}; echo "${t^}"   # Hello  (capitalize first char)
# stream: tr '[:upper:]' '[:lower:]'
```

### includes · s.includes(x)
```bash
[[ $s == *"$needle"* ]] && echo yes      # quote needle so * ? [ are literal
grep -qF -- "$needle" file               # in a file, fixed string
```

### startsWith · endsWith
```bash
[[ $s == "$prefix"* ]]
[[ $s == *"$suffix" ]]
```

### indexOf · s.indexOf(x)
```bash
before=${s%%"$x"*}
[[ $before == "$s" ]] && echo -1 || echo "${#before}"
# awk: awk -v n="$x" '{print index($0, n) - 1}'   (awk is 1-based, 0 = not found)
```

### slice · substring · substr · at(-1)
```bash
s="abcdef"
echo "${s:2}"        # cdef        s.slice(2)
echo "${s:1:3}"      # bcd         s.substr(1, 3)
echo "${s: -2}"      # ef          s.slice(-2)   (space before - matters)
echo "${s: -1}"      # f           s.at(-1)
echo "${s:0:${#s}-1}" # abcde      s.slice(0, -1)
```

### replace · replaceAll · strip prefix/suffix
```bash
echo "${s/foo/bar}"      # first occurrence   s.replace("foo","bar")
echo "${s//foo/bar}"     # all occurrences    s.replaceAll("foo","bar")
echo "${s#prefix}"       # remove shortest prefix match  (## = longest)
echo "${s%.txt}"         # remove suffix     path.basename(f, ".txt")
# regex replace on a stream: sed -E 's/[0-9]+/N/g'
```

### split · s.split(",")
```bash
IFS=, read -ra parts <<< "a,b,c"         # single-char delimiter; drops trailing empty field
printf '%s\n' "${parts[@]}"
# multi-char / JS-exact:
split() { local s=$1 d=$2; while [[ $s == *"$d"* ]]; do printf '%s\n' "${s%%"$d"*}"; s=${s#*"$d"}; done; printf '%s\n' "$s"; }
mapfile -t parts < <(split "k1::k2" "::")
# a column of a file: cut -d, -f2 file   |   awk -F, '{print $2}' file
```

### join · arr.join(",")
```bash
(IFS=,; echo "${arr[*]}")                # a,b,c   (single-char separator, subshell keeps IFS local)
printf '%s\n' "${arr[@]}" | paste -sd, - # any stream
```

### padStart · padEnd · repeat
```bash
printf '%05d\n' 42           # 00042         String(42).padStart(5,"0")
printf '%-10s|\n' "ab"       # "ab        |" padEnd
printf '%10s|\n' "ab"        # right-align
printf -- '-%.0s' {1..20}; echo   # "-".repeat(20)
```

### template literals · `Hello ${name}`
```bash
echo "Hello ${name}, you have $((n + 1)) items"
printf 'Hello %s, you have %d items\n' "$name" "$n"   # prefer printf for exact output
```

### multiline strings · heredoc
```bash
cat <<EOF                  # expands $vars
Dear $name,
EOF
cat <<'EOF'                # quoted: literal, no expansion (great for writing scripts)
echo $HOME
EOF
var=$(cat <<'EOF'
line 1
line 2
EOF
)
```

### regex · test / match / capture groups
```bash
if [[ $s =~ ^([a-z]+)-([0-9]+)$ ]]; then
  echo "${BASH_REMATCH[1]} ${BASH_REMATCH[2]}"   # m[1], m[2]
fi
# keep the regex in a variable to avoid quoting headaches:
re='^v([0-9]+)\.([0-9]+)'; [[ $tag =~ $re ]]
grep -oE '[0-9]{3}-[0-9]{4}' file   # matchAll → one match per line
```

### compare · empty check · equality
```bash
[[ $a == "$b" ]]      # string equal (right side quoted = literal, unquoted = glob)
[[ $a < "$b" ]]       # lexicographic
[[ -z $s ]]           # empty    (!s)
[[ -n $s ]]           # non-empty
(( a == b ))          # numeric — or [[ $a -eq $b ]]
```

---

## Numbers

### parseInt · Number() · validation
```bash
[[ $x =~ ^-?[0-9]+$ ]] || { echo "not an int" >&2; exit 1; }
echo $(( 10#$x ))      # force base 10: "08" would otherwise be invalid octal
echo $(( 16#ff ))      # parseInt("ff", 16) → 255
```

### math · Math.* · floats · toFixed
```bash
echo $(( 7 / 2 ))  $(( 7 % 2 ))  $(( 2 ** 10 ))   # 3 1 1024  — integers only
(( n++ )); (( total += x ))
echo "scale=2; 7 / 2" | bc                       # 3.50
awk 'BEGIN { printf "%.2f\n", 7 / 2 }'           # (7/2).toFixed(2)
printf '%.1f\n' 3.14159                          # 3.1
echo $(( a > b ? a : b ))                        # Math.max
```

### random · Math.random()
```bash
echo $(( RANDOM % 100 ))           # 0..99 (RANDOM is 0..32767)
shuf -i 1-100 -n 1                 # uniform in range
shuf -n 1 file                     # random line
```

---

## Arrays

### create · push · pop · length · index · last
```bash
arr=("a b" c d)            # const arr = ["a b","c","d"]
arr+=(e)                   # push
unset 'arr[-1]'            # pop (Bash 4.3+)
echo "${#arr[@]}"          # length
echo "${arr[0]}"  "${arr[-1]}"   # first, last
echo "${arr[@]:1:2}"       # slice(1, 3)
```

### for-of · forEach · for with index
```bash
for x in "${arr[@]}"; do echo "$x"; done          # for (const x of arr)
for i in "${!arr[@]}"; do echo "$i ${arr[i]}"; done   # arr.forEach((x, i) => …)
for ((i = 0; i < 10; i++)); do …; done            # classic for
for i in {1..5}; do …; done                       # range (literal bounds only)
for i in $(seq 1 "$n"); do …; done                # range with variables
```

### map · filter · find · some · every
```bash
upper=(); for x in "${arr[@]}"; do upper+=("${x^^}"); done      # map
evens=(); for n in "${nums[@]}"; do (( n % 2 == 0 )) && evens+=("$n"); done   # filter
# on streams it's one tool per method:
printf '%s\n' "${arr[@]}" | sed 's/^/item: /'     # map
printf '%s\n' "${arr[@]}" | grep -v '^tmp'        # filter
grep -m1 'pattern' file                           # find (first match)
grep -q 'pattern' file && echo some               # some
! grep -qv '^ok$' file && echo every              # every
```

### reduce · sum · count · min/max
```bash
sum=0; for n in "${nums[@]}"; do (( sum += n )); done
awk '{ s += $1 } END { print s }' numbers.txt     # sum a column
sort -n numbers.txt | tail -1                     # max
wc -l < file                                      # count lines (no filename in output)
```

### includes · indexOf on arrays
```bash
[[ " ${arr[*]} " == *" $x "* ]]     # quick and dirty, breaks on elements with spaces
contains() { local x=$1; shift; local e; for e; do [[ $e == "$x" ]] && return 0; done; return 1; }
contains "c" "${arr[@]}" && echo yes
```

### sort · reverse · unique · groupBy count
```bash
mapfile -t sorted < <(printf '%s\n' "${arr[@]}" | sort)      # arr.toSorted()
sort -n | sort -rn | sort -k2,2 -t,                          # numeric, desc, by column
tac file                                                     # reverse lines
sort -u file            # [...new Set(lines)].sort()
awk '!seen[$0]++' file  # unique, keeps first-seen order
sort | uniq -c | sort -rn   # count by value (groupBy + length)
```

### read lines into an array · readFileSync().split("\n")
```bash
mapfile -t lines < file               # aka readarray
mapfile -t files < <(find . -name '*.log')
```

### spread · ...args
```bash
cmd "${arr[@]}"          # each element is one argument: cmd(...arr)
all=("${a[@]}" "${b[@]}")   # [...a, ...b]
```

---

## Objects / Map / Set

### Map · object · associative array
```bash
declare -A user=([name]=ada [role]=admin)
user[team]=platform                  # set
echo "${user[name]}"                 # get
[[ -v user[role] ]] && echo has      # has (Bash 4.3+)
unset 'user[role]'                   # delete
for k in "${!user[@]}"; do echo "$k=${user[$k]}"; done   # Object.entries
echo "${#user[@]}"                   # size
```

### Set
```bash
declare -A seen
for x in "${items[@]}"; do seen[$x]=1; done
echo "${!seen[@]}"                   # unique values (unordered)
```

---

## Control flow

### if · else · comparison operators
```bash
if [[ -f $f && $n -gt 3 ]]; then …; elif (( n == 0 )); then …; else …; fi
# strings: == != < > -z -n =~      numbers: -eq -ne -lt -le -gt -ge, or (( a < b ))
# files:   -e exists -f file -d dir -r readable -w -x -s non-empty -L symlink  a -nt b (newer)
```

### ternary · a ? b : c
```bash
[[ $x == y ]] && v=yes || v=no        # careful: runs "v=no" if "v=yes" itself fails
v=$(( n > 0 ? 1 : 0 ))                # arithmetic ternary
v=${name:-anonymous}                  # name ?? "anonymous"
```

### switch · case
```bash
case $cmd in
  start|up)  start ;;
  stop)      stop ;;
  *.tar.gz)  extract "$cmd" ;;      # glob patterns
  *)         echo "unknown: $cmd" >&2; exit 2 ;;
esac
```

### while · do-while · break · continue · until
```bash
while (( n < 10 )); do (( n++ )); done
until curl -fs localhost:8080/health; do sleep 1; done     # retry loop
while true; do …; (( done )) && break; done                # do-while
```

### read a file line by line · for await (const line of rl)
```bash
while IFS= read -r line || [[ -n $line ]]; do
  echo "$line"
done < file
# fields: while IFS=, read -r id name rest; do …; done < file.csv
# from a command, keeping variables: while read -r x; do …; done < <(cmd)
```

---

## Functions

### define · args · return values
```bash
greet() {                    # function greet(name, greeting = "hi")
  local name=$1 greeting=${2:-hi}
  printf '%s, %s\n' "$greeting" "$name"     # "return" a value = print it
}
msg=$(greet ada hello)                      # capture
is_even() { (( $1 % 2 == 0 )); }            # return a boolean = exit status
if is_even 4; then …; fi
```

### arguments · process.argv · rest params
```bash
echo "$0"        # script name
echo "$1" "$2"   # positional args
echo "$#"        # count
"$@"             # all args, each preserved  (…args)
shift            # drop $1   (args.slice(1))
```

### flags · getopts · CLI parsing
```bash
verbose=0 out=
while getopts ':vo:' opt; do
  case $opt in
    v) verbose=1 ;;
    o) out=$OPTARG ;;
    :) echo "-$OPTARG needs a value" >&2; exit 2 ;;
    ?) echo "unknown -$OPTARG" >&2; exit 2 ;;
  esac
done
shift $((OPTIND - 1))        # remaining positional args
```

---

## Errors

### throw · process.exit · exit codes
```bash
die() { echo "error: $*" >&2; exit 1; }       # throw new Error(msg)
[[ -r $f ]] || die "cannot read $f"
return 3      # from a function
exit 2        # from the script (2 = usage error by convention)
```

### try / catch
```bash
if ! out=$(risky 2>&1); then echo "failed: $out" >&2; fi
risky || echo "fallback"                       # catch → fallback
{ step1 && step2; } || { echo "rollback" >&2; rollback; }
```

### finally · cleanup · trap
```bash
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT                   # runs on normal exit, error, Ctrl-C, TERM
trap 'echo "failed at line $LINENO" >&2' ERR
```

### strict mode · "use strict"
```bash
set -euo pipefail     # exit on error, error on unset vars, fail pipelines on any stage
# -e is skipped inside if/while conditions and around && || — still validate explicitly
```

### console.error · stderr · logging
```bash
echo "warning: disk at 91%" >&2
log() { printf '%s %s\n' "$(date +%FT%T)" "$*" >&2; }
```

### null / undefined · defaults · required
```bash
${var:-default}     # var ?? "default" (also when empty)
${var:=default}     # var ??= "default"
${var:?is required} # throw if unset/empty
${var:+alt}         # var ? "alt" : ""
[[ -v var ]]        # declared?  (unset ≠ empty)
```

---

## Files (fs, path)

### readFileSync · read a whole file
```bash
content=$(<file)              # no cat needed; strips trailing newlines
```

### writeFileSync · appendFileSync
```bash
printf '%s\n' "$content" > file       # overwrite
echo "line" >> file                   # append
{ echo a; echo b; } > file            # group writes
printf '%s\n' "$x" | sudo tee /etc/x >/dev/null   # write root-owned file
```

### existsSync · stat · size · mtime
```bash
[[ -e $p ]]  [[ -f $p ]]  [[ -d $p ]]
stat -c '%s bytes, %y, mode %a, owner %U' file
find . -newer ref.txt                 # modified after
```

### mkdir -p · rm -rf · cp · mv
```bash
mkdir -p a/b/c                        # { recursive: true }
rm -rf -- "$dir"                      # "--" stops option parsing
cp -a src/ dst/                       # preserve perms/times
mv -n -- "$a" "$b"                    # don't overwrite
```

### readdirSync · glob · walk
```bash
shopt -s nullglob; for f in *.log; do …; done      # one level
find . -type f -name '*.ts' -print0 | while IFS= read -r -d '' f; do …; done   # recursive, safe
find . -type f -name '*.ts' -exec wc -l {} +       # run a command on all of them
```

### path.basename · dirname · extname · join · resolve
```bash
p=/a/b/file.tar.gz
echo "${p##*/}"   "$(basename -- "$p")"      # file.tar.gz
echo "${p%/*}"    "$(dirname -- "$p")"       # /a/b
echo "${p##*.}"                               # gz       (extname without dot)
echo "${p%%.*}"                               # /a/b/file
echo "$dir/$name"                             # path.join (mind double slashes)
realpath -- "$rel"                            # path.resolve
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)   # __dirname
```

### temp files · os.tmpdir()
```bash
tmp=$(mktemp)  dir=$(mktemp -d)  ; trap 'rm -rf -- "$tmp" "$dir"' EXIT
```

---

## JSON

### JSON.parse · property access · filter
```bash
jq -r '.name' f.json
jq -r '.items[] | select(.active) | .id' f.json
jq -r '.items | length' f.json
jq -r '.items | map(.price) | add' f.json
jq -r '.items[] | [.id, .name] | @tsv' f.json
jq -r '.a.b // "default"' f.json             # ?? operator
```

### JSON.stringify · build JSON safely
```bash
jq -n --arg name "$name" --argjson n 3 '{name: $name, count: $n}'
jq --arg v "$v" '.version = $v' in.json > out.json && mv out.json in.json
```

---

## Processes & async

### execSync · capture command output
```bash
out=$(git rev-parse HEAD)            # stdout only, trailing newlines stripped
out=$(cmd 2>&1)                      # include stderr
if cmd; then …; fi                   # just the success
```

### spawn · background · Promise.all · Promise.race
```bash
job1 & p1=$!
job2 & p2=$!
wait "$p1"; r1=$?                    # await, with exit status
wait "$p2"; r2=$?
wait -n                              # Promise.race: first to finish
xargs -P 4 -n 1 ./work.sh < ids.txt  # pool of 4 workers
```

### setTimeout · setInterval · timeout
```bash
sleep 2                              # await sleep(2000)
while true; do check; sleep 5; done  # setInterval
timeout 10 cmd || echo "timed out (124)"   # Promise.race with a timer
```

### process.on('SIGTERM') · signals
```bash
trap 'echo "bye"; exit 0' TERM INT
kill -TERM "$pid"; kill -0 "$pid"    # signal / is it alive?
```

### process.env · export · dotenv
```bash
echo "${HOME}" "${PORT:-8080}"
export API_URL=http://x               # visible to child processes
API_URL=http://y ./app                # only for this command
set -a; source .env; set +a           # load a .env file
env | sort                            # dump environment
```

### process.cwd · chdir
```bash
pwd; cd -- "$dir" || exit 1
( cd /tmp && do_stuff )              # subshell: cwd change doesn't leak
pushd "$dir" >/dev/null; …; popd >/dev/null
```

### readline · prompt for input
```bash
read -rp "Name? " name
read -rsp "Password? " pw; echo      # silent
read -t 5 -rp "Continue? [y/N] " ans || ans=n   # with timeout
```

### Date · Date.now() · toISOString
```bash
date +%s              # epoch seconds        Math.floor(Date.now()/1000)
date +%s%3N           # epoch millis         Date.now()
date -u +%FT%TZ       # 2026-10-16T09:00:00Z toISOString()
date -d '+1 day' +%F  # date math (GNU)
date -d @1700000000   # from epoch
start=$SECONDS; …; echo "took $((SECONDS - start))s"
```

---

## Pipelines as method chains

### arr.filter().map().sort().slice()
```bash
# logs.filter(l => l.includes("ERROR")).map(l => l.split(" ")[2]).sort().slice(0, 5)
grep 'ERROR' app.log | awk '{print $3}' | sort | head -n 5
```

### grep options you should know
```bash
grep -i (ignore case) -v (invert) -c (count) -n (line numbers) -l (files only)
     -r (recursive) -w (word) -x (whole line) -F (fixed string) -E (extended regex)
     -o (only match) -A2 -B2 -C2 (context) -q (quiet, for if) -m1 (first match)
```

### cut · tr · wc · head · tail · sort · uniq · paste · column
```bash
cut -d: -f1,7 /etc/passwd          # fields 1 and 7
tr -d '\r' ; tr -s ' '             # delete CR ; squeeze spaces
wc -l -w -c                        # lines words bytes
head -n 5 ; tail -n 5 ; tail -f log ; tail -n +2 (skip header)
sort -t, -k3,3n -k1,1 ; sort -h (human sizes 1K 2M)
uniq -c ; uniq -d (dupes only)
paste -sd+ nums | bc               # sum via join("+")
column -t -s,                      # pretty-print a table
```

### awk in 6 lines
```bash
awk '{print $1, $NF}'                          # first and last field
awk -F, 'NR > 1 && $3 > 100'                   # filter rows (skip header)
awk '{s[$1] += $2} END {for (k in s) print k, s[k]}'   # group-by sum
awk -v min="$min" '$2 >= min'                  # pass shell variables
awk 'length > 80'                              # long lines
awk 'NR % 2'                                   # odd lines
```

### sed in 6 lines
```bash
sed 's/old/new/g'          # replaceAll
sed -n '10,20p'            # lines 10–20
sed '/^#/d; /^$/d'         # drop comments and blanks
sed -i.bak 's/^port=.*/port=8080/' conf   # in place with backup
sed -E 's/([0-9]+)-([0-9]+)/\2-\1/'       # capture groups
sed '1i header' ; sed '$a footer'         # insert first / append last
```

### xargs
```bash
find . -name '*.log' -print0 | xargs -0 gzip      # safe filenames
xargs -n1 -P4 curl -sO < urls.txt                 # parallel downloads
cmd | xargs -I{} mv {} {}.bak                     # placeholder
```

---

## Gotchas that bite TypeScript people

### quoting · word splitting · globbing
```bash
f="my file.txt"
rm $f        # rm "my" "file.txt"  ← two args!
rm "$f"      # correct
echo $var    # also glob-expands * in the value
```

### assignment has no spaces · = vs ==
```bash
x=1          # ok
x = 1        # runs command "x" with args "=" "1"
[[ $a = b ]] # = and == are the same inside [[ ]]
```

### [ vs [[ vs ((
```bash
[ ]   POSIX test command: quote everything, no && inside, use -a/-o (avoid)
[[ ]] Bash keyword: no word splitting, supports && || =~ and globs. Use this.
(( )) arithmetic: C-like, variables without $, returns 1 when the result is 0
```

### $(…) strips trailing newlines · echo vs printf
```bash
x=$(printf 'a\n\n')   # x="a"
echo -n / echo -e     # behave differently across shells; printf is portable and exact
```

### arrays: "${arr[@]}" vs ${arr[*]} vs $arr
```bash
"${arr[@]}"  each element separately (what you want 99% of the time)
"${arr[*]}"  one string joined with first char of IFS
$arr         only the FIRST element (like arr[0])
```

### subshells lose variables
```bash
cat f | while read -r l; do n=$((n+1)); done; echo "$n"   # 0 — loop ran in a subshell
while read -r l; do n=$((n+1)); done < f; echo "$n"       # correct
```

### local and exit codes
```bash
local x=$(cmd)   # $? is local's status (0), not cmd's — declare first: local x; x=$(cmd)
```
