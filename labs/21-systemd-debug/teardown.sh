systemctl disable --now inventory 2>/dev/null
rm -rf /etc/systemd/system/inventory.service /etc/systemd/system/inventory.service.d /opt/inventory /var/lib/inventory
systemctl daemon-reload
systemctl reset-failed inventory 2>/dev/null
rm -f "$KATA_RUN/21.sha"
true
