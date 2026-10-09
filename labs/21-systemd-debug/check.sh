compare_str "inventory.sh content is unchanged" "$(sha256sum /opt/inventory/inventory.sh 2>/dev/null | cut -d' ' -f1)" < "$KATA_RUN/21.sha"
assert "ExecStart still runs /opt/inventory/inventory.sh" grep -q '/opt/inventory/inventory.sh' <<< "$(systemctl show -p ExecStart --value inventory)"
assert "inventory is enabled" systemctl is-enabled --quiet inventory
healthy() { systemctl is-active --quiet inventory && journalctl -u inventory --no-pager -n 20 | grep -q 'inventory: 3 items'; }
wait_for 4 healthy
sleep 1
assert "inventory is active (and stays up)" systemctl is-active --quiet inventory
assert "journal shows 'inventory: 3 items'" healthy
