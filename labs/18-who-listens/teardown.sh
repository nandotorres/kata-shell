for f in "$KATA_RUN"/18.*.pid; do
  [[ -f $f ]] && kill "$(cat "$f")" 2>/dev/null
  rm -f "$f"
done
true
