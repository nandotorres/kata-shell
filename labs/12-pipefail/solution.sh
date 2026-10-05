cat > report.sh <<'EOF'
#!/usr/bin/env bash
# Usage: ./report.sh FILE — prints the 3 biggest orders, then "REPORT OK"
set -euo pipefail
cat "$1" | sort -t, -k2 -rn | head -n 3
echo "REPORT OK"
EOF
