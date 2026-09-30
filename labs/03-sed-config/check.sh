compare "app.conf is patched (port, debug, no legacy_*)" app.conf <<'EOF'
# app.conf — hand maintained, sorry
name=inventory
port=8080
upstream_port=8000
debug=true
workers=4
log_level=info
EOF
compare "app.conf.bak is the untouched original" app.conf.bak <<'EOF'
# app.conf — hand maintained, sorry
name=inventory
port=80
upstream_port=8000
#debug=true
legacy_mode=on
workers=4
legacy_cache=/tmp/old
log_level=info
EOF
