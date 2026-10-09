assert "/etc/systemd/system/greeter.service exists" test -f /etc/systemd/system/greeter.service || return
assert "greeter is enabled (starts at boot)" systemctl is-enabled --quiet greeter
assert "greeter is active (running now)" systemctl is-active --quiet greeter
exec_start=$(systemctl show -p ExecStart --value greeter)
assert "ExecStart runs /opt/greeter/greeter.sh" grep -q '/opt/greeter/greeter.sh' <<< "$exec_start"
logs_ok() { journalctl -u greeter --no-pager -n 50 | grep -q 'greeter: hello'; }
wait_for 6 logs_ok
assert "its output is in the journal" logs_ok

old=$(systemctl show -p MainPID --value greeter)
if [[ $old =~ ^[1-9][0-9]*$ ]]; then
  kill -9 "$old"
  restarted() { local p; p=$(systemctl show -p MainPID --value greeter); [[ $p != 0 && $p != "$old" ]] && systemctl is-active --quiet greeter; }
  wait_for 8 restarted
  assert "after kill -9, systemd restarted it (old PID $old)" restarted
else
  _ko "greeter has a main PID to crash-test"
fi
