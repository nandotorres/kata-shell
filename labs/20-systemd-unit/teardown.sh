systemctl disable --now greeter 2>/dev/null
rm -f /etc/systemd/system/greeter.service
rm -rf /etc/systemd/system/greeter.service.d /opt/greeter
systemctl daemon-reload
systemctl reset-failed greeter 2>/dev/null
true
