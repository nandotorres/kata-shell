hog=$(cat "$KATA_RUN/15.hog")
compare_str "hog.pid has the hog's PID" "$(tr -d '[:space:]' < hog.pid 2>/dev/null)" <<< "$hog"
gone() { ! kill -0 "$hog" 2>/dev/null; }
wait_for 3 gone
assert "the hog is no longer running" gone
assert "it exited gracefully on SIGTERM (not kill -9)" grep -q 'got SIGTERM' "$KATA_RUN/15.log"
alive=0
while read -r pid; do kill -0 "$pid" 2>/dev/null && alive=$((alive + 1)); done < "$KATA_RUN/15.others"
assert "the two healthy workers are still running ($alive/2)" test "$alive" -eq 2
