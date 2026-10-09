systemctl disable --now cleanup.timer 2>/dev/null
systemctl stop cleanup.service 2>/dev/null
rm -f /etc/systemd/system/cleanup.service /etc/systemd/system/cleanup.timer
rm -rf /var/tmp/kata-junk
systemctl daemon-reload
systemctl reset-failed cleanup.service cleanup.timer 2>/dev/null
true
