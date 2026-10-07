cat > worker.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

tmp=$(mktemp)
echo "$tmp" > worker.tmp-path

cleanup()  { rm -f -- "$tmp"; }
shutdown() { echo "graceful shutdown" >> worker.log; exit 0; }
trap cleanup EXIT
trap shutdown TERM INT

while true; do
  sleep 1 & wait $!      # wait is interruptible, so the trap fires immediately
done
EOF
