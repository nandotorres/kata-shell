assert "strings.sh exists" test -f strings.sh || return

actual=$(PATH='' /bin/bash --norc --noprofile -c '
  source ./strings.sh || exit 99
  yn() { if "$@"; then printf yes; else printf no; fi; }
  printf "trim        [%s]\n" "$(trim "   hi there  ")"
  printf "trim tabs   [%s]\n" "$(trim "$(printf "\t x y \n")")"
  printf "lower       [%s]\n" "$(lower "HeLLo WoRLD")"
  printf "upper       [%s]\n" "$(upper "shell kata")"
  printf "replace_all [%s]\n" "$(replace_all "a-b-c-d" "-" "+")"
  printf "replace *   [%s]\n" "$(replace_all "2*3*4" "*" " x ")"
  printf "starts_with [%s %s]\n" "$(yn starts_with "foobar" "foo")" "$(yn starts_with "foobar" "bar")"
  printf "starts glob [%s]\n" "$(yn starts_with "foobar" "*")"
  printf "includes    [%s %s]\n" "$(yn includes "needle in hay" "in h")" "$(yn includes "hay" "needle")"
  printf "index_of    [%s %s %s]\n" "$(index_of "hello world" "o w")" "$(index_of "hello" "h")" "$(index_of "hello" "z")"
  printf "split       [%s]\n" "$(split "a,b,,c," "," | while IFS= read -r p; do printf "<%s>" "$p"; done)"
  printf "split multi [%s]\n" "$(split "k1::k2::k3" "::" | while IFS= read -r p; do printf "<%s>" "$p"; done)"
  printf "pad_start   [%s %s]\n" "$(pad_start 7 3 0)" "$(pad_start 12345 3 0)"
' 2>&1)

compare_str "functions behave like their TypeScript twins (PATH is empty)" "$actual" <<'EOF'
trim        [hi there]
trim tabs   [x y]
lower       [hello world]
upper       [SHELL KATA]
replace_all [a+b+c+d]
replace *   [2 x 3 x 4]
starts_with [yes no]
starts glob [no]
includes    [yes no]
index_of    [4 0 -1]
split       [<a><b><><c><>]
split multi [<k1><k2><k3>]
pad_start   [007 12345]
EOF
