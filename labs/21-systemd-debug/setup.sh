mkdir -p /opt/inventory /var/lib/inventory
cat > /opt/inventory/inventory.sh <<'EOF'
#!/usr/bin/env bash
: "${INVENTORY_DB:?INVENTORY_DB is not set}"
if [[ ! -r $INVENTORY_DB ]]; then
  echo "inventory: cannot read database '$INVENTORY_DB'" >&2
  exit 1
fi
while true; do
  echo "inventory: $(wc -l < "$INVENTORY_DB") items"
  sleep 10
done
EOF
chmod 644 /opt/inventory/inventory.sh
printf 'widget\ngadget\ngizmo\n' > /var/lib/inventory/items.txt
sha256sum /opt/inventory/inventory.sh | cut -d' ' -f1 > "$KATA_RUN/21.sha"

cat > /etc/systemd/system/inventory.service <<'EOF'
[Unit]
Description=Inventory API

[Service]
ExecStart=/opt/inventory/inventory.sh
Environment=INVENTORY_DB=/var/lib/inventory/items.db

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl start inventory 2>/dev/null || true
