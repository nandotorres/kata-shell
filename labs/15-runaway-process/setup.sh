mkdir -p .svc
names=(report-builder cache-warmer mail-relay)
hog=${names[RANDOM % 3]}
for n in "${names[@]}"; do
  if [[ $n == "$hog" ]]; then
    cat > ".svc/$n" <<EOF
#!/usr/bin/env bash
trap 'echo "\$(date +%T) $n got SIGTERM, exiting cleanly" >> "$KATA_RUN/15.log"; exit 0' TERM
while (( SECONDS < 1800 )); do :; done
EOF
  else
    cat > ".svc/$n" <<'EOF'
#!/usr/bin/env bash
while (( SECONDS < 1800 )); do sleep 1; done
EOF
  fi
  chmod +x ".svc/$n"
  setsid -f "$KATA_WORK/.svc/$n" >/dev/null 2>&1 < /dev/null
done
rm -f "$KATA_RUN/15.log"
for n in "${names[@]}"; do
  for _ in $(seq 50); do pgrep -f "/.svc/$n\$" >/dev/null && break; sleep 0.1; done
done
pgrep -f "/.svc/$hog\$" > "$KATA_RUN/15.hog"
pgrep -f "$KATA_WORK/.svc/" | grep -vx "$(cat "$KATA_RUN/15.hog")" > "$KATA_RUN/15.others"
sleep 1   # let the hog rack up some CPU time
