cat > app.conf <<'EOF'
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
