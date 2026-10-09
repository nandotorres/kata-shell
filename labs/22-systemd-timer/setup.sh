mkdir -p /var/tmp/kata-junk
for i in 1 2 3 4; do printf 'junk\n' > "/var/tmp/kata-junk/session-$i.junk"; done
printf 'do not delete\n' > /var/tmp/kata-junk/keep.txt
