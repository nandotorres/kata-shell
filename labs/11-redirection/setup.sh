cat > noisy <<'EOF'
#!/usr/bin/env bash
echo "out: starting"
echo "err: config missing, using defaults" >&2
echo "out: processed 3 items"
echo "err: item 2 was slow" >&2
echo "out: done"
exit 3
EOF
chmod +x noisy
