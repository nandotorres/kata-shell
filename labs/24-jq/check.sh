compare "down.txt: services not up, sorted" down.txt <<'EOF'
billing
email
search
EOF
compare "by-region.tsv: REGION<TAB>COUNT, sorted" by-region.tsv < <(printf 'ap-south\t2\neu-west\t3\nus-east\t2\n')
compare "slowest.txt: slowest service that is up" slowest.txt <<'EOF'
reports
EOF
