assert "deploy.sh is executable" test -x deploy.sh
refute "deploy.sh has no carriage returns (\\r)" grep -q $'\r' deploy.sh
compare "deploy.sh content is unchanged apart from line endings" deploy.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "deployed version 1.4.2" > deployed.txt
EOF

scratch=$(mktemp -d)
cp deploy.sh "$scratch/" 2>/dev/null
assert "./deploy.sh runs successfully" bash -c "cd '$scratch' && ./deploy.sh"
compare "running it produces deployed.txt" "$scratch/deployed.txt" <<'EOF'
deployed version 1.4.2
EOF
rm -rf "$scratch"
