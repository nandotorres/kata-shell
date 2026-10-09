mkdir -p /opt/greeter
cat > /opt/greeter/greeter.sh <<'EOF'
#!/usr/bin/env bash
while true; do
  echo "greeter: hello from PID $$"
  sleep 5
done
EOF
chmod 755 /opt/greeter/greeter.sh
