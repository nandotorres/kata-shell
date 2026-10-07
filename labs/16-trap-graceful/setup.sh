cat > worker.sh <<'EOF'
#!/usr/bin/env bash
# Long-running worker. TODO: temp file, signal handling, cleanup.
while true; do
  sleep 1
done
EOF
chmod +x worker.sh
