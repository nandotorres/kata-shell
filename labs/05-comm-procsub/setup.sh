cat > employees.txt <<'EOF'
trent
alice
mallory
carol
bob
walter
judy
heidi
olivia
erin
dave
niaj
frank
peggy
grace
sybil
ivan
rupert
victor
EOF

swipers=(alice bob carol dave erin frank grace ivan judy mallory olivia peggy rupert trent victor oscar zoe)
for i in $(seq 1 80); do
  name=${swipers[$(( (i * 7 + i / 3) % ${#swipers[@]} ))]}
  printf '2026-10-%02dT%02d:%02d %s door-%d\n' $((1 + i % 15)) $((7 + i % 11)) $((i * 13 % 60)) "$name" $((1 + i % 4))
done > badge-swipes.log
# make sure every swiper appears at least once
for name in "${swipers[@]}"; do printf '2026-10-16T08:00 %s door-1\n' "$name"; done >> badge-swipes.log
