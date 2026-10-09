# Turn a script into a real service
> Track: systemd · Level ★★☆ · ~12 min

## Statement
`/opt/greeter/greeter.sh` currently runs as `nohup ./greeter.sh &` on a server, which is fragile. Make it a proper systemd service named `greeter`:
- it runs now,
- it starts at boot,
- systemd **restarts it automatically** if it crashes or gets killed,
- its output goes to the journal.

## Current state
- `/opt/greeter/greeter.sh` exists and is executable. It prints a line every 5 seconds.
- There is no `greeter.service` yet (`systemctl status greeter` says "could not be found").

## Done when
`greeter` is active and enabled, its output is in `journalctl -u greeter`, and when the checker `kill -9`s it, systemd brings it back with a new PID.

## Hint
Write `/etc/systemd/system/greeter.service` with `[Unit]`, `[Service]` (`ExecStart=`, `Restart=`) and `[Install]` (`WantedBy=multi-user.target`).
Then `systemctl daemon-reload` and `systemctl enable --now greeter`.

## Key idea
A unit file tells systemd what to run (`ExecStart=`), when (`WantedBy=` + `enable`) and what to do when it dies (`Restart=`), and `daemon-reload` makes systemd re-read your edits.

## Deep dive
- `systemctl cat greeter` shows the effective unit and `systemctl show -p Restart,MainPID greeter` shows parsed properties.
- `enable` creates a symlink in `multi-user.target.wants/`. It does **not** start the service. `--now` does both.
- `Type=simple` (default) treats the process as the service. `forking` is for daemons that background themselves, `oneshot` for run-to-completion jobs, `notify` for services that signal readiness.
- `Restart=on-failure` covers non-zero exits and signals, and `always` also covers clean exits. Rate limiting is controlled by `StartLimitBurst=`/`StartLimitIntervalSec=`.
- Hardening one-liners: `User=nobody`, `ProtectSystem=strict`, `PrivateTmp=yes`, `NoNewPrivileges=yes`.
- `journalctl -u greeter -f` follows logs, `-b` limits to this boot, `--since "10 min ago"`, `-p err` filters errors only.
