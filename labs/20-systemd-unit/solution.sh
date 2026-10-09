cat > /etc/systemd/system/greeter.service <<'EOF'
[Unit]
Description=Greeter demo service
After=network.target

[Service]
ExecStart=/opt/greeter/greeter.sh
Restart=on-failure
RestartSec=1

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now greeter
systemctl status greeter --no-pager
