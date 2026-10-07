[[ -f $KATA_RUN/19.pid ]] && kill "$(cat "$KATA_RUN/19.pid")" 2>/dev/null
rm -f "$KATA_RUN/19.pid"
true
