cat > report.sh <<'EOF'
#!/usr/bin/env bash
# Usage: ./report.sh FILE — prints the 3 biggest orders, then "REPORT OK"
cat "$1" | sort -t, -k2 -rn | head -n 3
echo "REPORT OK"
EOF
chmod +x report.sh
cat > orders.csv <<'EOF'
A100,250
A101,1200
A102,75
A103,980
A104,4100
A105,310
EOF
