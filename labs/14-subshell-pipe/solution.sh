cat > count.sh <<'EOF'
#!/usr/bin/env bash
# Prints how many servers in servers.txt are "up", then their names.
count=0
up=()
while read -r name state || [[ -n $name ]]; do
  if [[ $state == up ]]; then
    count=$((count + 1))
    up+=("$name")
  fi
done < servers.txt
echo "up: $count"
echo "names: ${up[*]}"
EOF
