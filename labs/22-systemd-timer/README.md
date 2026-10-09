# Replace a cron job with a systemd timer
> Track: systemd · Level ★★☆ · ~10 min

## Statement
The old crontab line was:
```
* * * * *  find /var/tmp/kata-junk -type f -name '*.junk' -delete
```
Replace it with systemd: a `cleanup.service` that does the deletion **once and exits**, and a `cleanup.timer`
that triggers it **every minute**. The timer must be enabled (survives reboot) and active.

## Current state
- `/var/tmp/kata-junk/` contains `*.junk` files plus a `keep.txt` that must survive.
- No `cleanup.*` units exist.

## Done when
`cleanup.timer` is enabled and active and triggers `cleanup.service`, the service is `Type=oneshot`, and starting it deletes the junk but not `keep.txt`.

## Hint
Service: `[Service] Type=oneshot` + `ExecStart=/usr/bin/find …` (absolute path; no shell features unless you wrap in `/bin/sh -c`).
Timer: `[Timer] OnCalendar=minutely` (or `OnCalendar=*-*-* *:*:00`), `[Install] WantedBy=timers.target`. Then `systemctl enable --now cleanup.timer`.

## Key idea
A `.timer` unit activates the same-named `.service` on a schedule, which gives you cron plus journald logging, dependencies and `systemctl list-timers` to see the next run.

## Deep dive
- `systemd-analyze calendar 'Mon..Fri 09:00'` validates and explains `OnCalendar=` expressions.
- Monotonic timers: `OnBootSec=5min`, `OnUnitActiveSec=1h` (relative to the last run).
- `Persistent=true` runs a missed job after downtime (like anacron).
- Enable the **timer**, not the service. The service has no `[Install]` section.
- Debug a run: `systemctl start cleanup.service` and then `journalctl -u cleanup.service`.
