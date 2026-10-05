cat > count.sh <<'EOF'
#!/usr/bin/env bash
# Prints how many servers in servers.txt are "up", then their names.
count=0
up=()
cat servers.txt | while read -r name state; do
  if [[ $state == up ]]; then
    count=$((count + 1))
    up+=("$name")
  fi
done
echo "up: $count"
echo "names: ${up[*]}"
EOF
chmod +x count.sh
printf 'web1 up\nweb2 up\ndb1 up\ndb2 down\nqueue1 maintenance\ncache1 up' > servers.txt
