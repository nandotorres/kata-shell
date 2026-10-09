assert "cleanup.timer is enabled" systemctl is-enabled --quiet cleanup.timer
assert "cleanup.timer is active" systemctl is-active --quiet cleanup.timer
assert "the timer triggers cleanup.service" grep -qw 'cleanup.service' <<< "$(systemctl show -p Triggers --value cleanup.timer)"
schedule=$(systemctl show -p TimersCalendar -p TimersMonotonic --value cleanup.timer | tr '\n' ' ')
assert "the timer has a schedule ($schedule)" grep -qE 'OnCalendar|OnUnitActive|OnBoot|OnActive' <<< "$schedule"
assert "cleanup.service is Type=oneshot" test "$(systemctl show -p Type --value cleanup.service)" = oneshot

printf 'junk\n' > /var/tmp/kata-junk/checker.junk
systemctl start cleanup.service 2>/dev/null
refute "running cleanup.service deletes *.junk" compgen -G '/var/tmp/kata-junk/*.junk'
assert "keep.txt survives" test -f /var/tmp/kata-junk/keep.txt
