cat > job.sh <<'EOF'
#!/usr/bin/env bash
# job.sh N — pretends to do 2s of work
sleep 2
if [[ $1 == 3 ]]; then echo "job $1: upstream timeout" >&2; exit 7; fi
echo "job $1: ok"
EOF
chmod +x job.sh
