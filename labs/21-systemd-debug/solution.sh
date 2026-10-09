systemctl status inventory --no-pager            # failed, status=203/EXEC
journalctl -u inventory -n 20 --no-pager         # "Permission denied" executing the script
chmod +x /opt/inventory/inventory.sh
systemctl restart inventory; sleep 1
journalctl -u inventory -n 5 --no-pager          # "cannot read database '/var/lib/inventory/items.db'"
ls /var/lib/inventory                            # the real file is items.txt

mkdir -p /etc/systemd/system/inventory.service.d
cat > /etc/systemd/system/inventory.service.d/override.conf <<'EOF'
[Service]
Environment=INVENTORY_DB=/var/lib/inventory/items.txt
EOF
systemctl daemon-reload
systemctl enable inventory
systemctl restart inventory
