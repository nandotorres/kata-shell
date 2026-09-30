cat > strings.sh <<'EOF'
# strings.sh — String.prototype for Bash. Only builtins allowed (checker runs with PATH="").
# Each function prints its result (no trailing newline), except split (one element per line).

trim()        { :; }   # trim S
lower()       { :; }   # lower S
upper()       { :; }   # upper S
replace_all() { :; }   # replace_all S FROM TO
starts_with() { :; }   # starts_with S PREFIX   -> exit 0/1
includes()    { :; }   # includes S NEEDLE      -> exit 0/1
index_of()    { :; }   # index_of S NEEDLE      -> position or -1
split()       { :; }   # split S DELIM          -> one element per line
pad_start()   { :; }   # pad_start S LEN CHAR
EOF
