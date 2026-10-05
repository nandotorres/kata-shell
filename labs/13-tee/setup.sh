cat > build <<'EOF'
#!/usr/bin/env bash
echo "[1/6] resolving dependencies"
echo "WARN: package left-pad is deprecated" >&2
echo "[2/6] compiling core"
echo "[3/6] compiling plugins"
echo "WARN: plugin 'legacy' has no tests" >&2
echo "[4/6] linking"
echo "note: warnings are not errors (yet)"
echo "[5/6] running unit tests: 142 passed"
echo "WARN: 3 tests skipped"
echo "[6/6] packaging build-1.4.2.tar.gz"
echo "WARN: artifact not signed" >&2
echo "BUILD SUCCESS"
EOF
chmod +x build
