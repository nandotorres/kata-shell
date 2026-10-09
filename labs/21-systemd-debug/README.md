# A failed service: read the journal, fix it
> Track: systemd · Level ★★★ · ~12 min

## Statement
`inventory.service` is **failed** and the on-call channel is on fire. Get it **running** and **enabled**.
Rules: don't edit or replace `/opt/inventory/inventory.sh` (permissions are fair game), and keep using
that script as `ExecStart`. Fix the environment and configuration instead.

## Current state
- `systemctl status inventory` shows `failed`.
- The script and its data live under `/opt/inventory` and `/var/lib/inventory`.
- There's more than one problem.

## Done when
`inventory` is active and enabled, still runs the original script unchanged, and logs `inventory: 3 items`.

## Hint
`systemctl status inventory` tells you **that** it failed. `journalctl -u inventory -e --no-pager` tells you **why**.
Status `203/EXEC` means systemd couldn't execute the file. After fixing one thing, restart and read the journal again.
Prefer a drop-in (`systemctl edit inventory`, or a file in `/etc/systemd/system/inventory.service.d/`) to editing the unit itself.

## Key idea
`systemctl status` tells you that a service failed and `journalctl -u <unit>` tells you why, so read the journal first, fix one thing, then restart and read it again.

## Deep dive
- Common exit statuses: `203/EXEC` (not executable / bad shebang / missing), `200/CHDIR`, `217/USER` (unknown `User=`), and `status=1/FAILURE` (the program itself failed, so its own message is in the journal).
- `systemctl edit X` writes a drop-in `override.conf`, and `systemctl cat X` shows the unit plus every drop-in.
- `systemctl show X -p Environment` shows the parsed env. `systemd-analyze verify X.service` lints a unit.
- "Start request repeated too quickly" means the start limit was hit, so run `systemctl reset-failed X` before starting again.
- `systemctl list-units --failed` is the first command to run on a sick box.
