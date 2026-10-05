compare_str "./count.sh on servers.txt" "$(./count.sh 2>&1)" <<'EOF'
up: 4
names: web1 web2 db1 cache1
EOF

scratch=$(mktemp -d)
cp count.sh "$scratch/"
printf 'a down\nb up\nc up\n' > "$scratch/servers.txt"
compare_str "./count.sh on a different servers.txt (no hardcoding)" "$(cd "$scratch" && ./count.sh 2>&1)" <<'EOF'
up: 2
names: b c
EOF
rm -rf "$scratch"
