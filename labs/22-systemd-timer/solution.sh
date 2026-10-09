cat > /etc/systemd/system/cleanup.service <<'EOF'
[Unit]
Description=Delete stale junk files

[Service]
Type=oneshot
ExecStart=/usr/bin/find /var/tmp/kata-junk -type f -name *.junk -delete
EOF

cat > /etc/systemd/system/cleanup.timer <<'EOF'
[Unit]
Description=Run cleanup.service every minute

[Timer]
OnCalendar=minutely
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now cleanup.timer
systemctl list-timers cleanup.timer --no-pager
