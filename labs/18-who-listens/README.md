# Who is listening on that port?
> Track: Processes & signals · Level ★★☆ · ~8 min

## Statement
Something answers on port 8081 and nobody knows what. Also, security wants to know which ports are exposed
on **all interfaces** (`0.0.0.0`) rather than only on localhost. Write `answer.txt`:
```
pid=<PID of the process listening on TCP 8081>
public_ports=<TCP ports bound to 0.0.0.0, ascending, space separated>
```

## Current state
- The lab started three TCP listeners under disguised process names. Some are bound to `127.0.0.1`, some to `0.0.0.0`.

## Done when
`answer.txt` has the right PID and the right list of public ports.

## Hint
`ss -ltnp`: **l**istening, **t**cp, **n**umeric (no DNS/service names), **p**rocess. The `Local Address:Port` column tells you the bind address.
`ps -p PID -o pid,args` shows what a PID really is.

## Key idea
`ss -ltnp` maps listening ports to PIDs and bind addresses: `127.0.0.1` is reachable only from the box itself, while `0.0.0.0` (or `*`, `[::]`) accepts connections from anywhere.

## Deep dive
- `ss -tanp state established` shows live connections. `ss -s` gives a summary.
- `lsof -iTCP:8081 -sTCP:LISTEN` is the lsof equivalent. `fuser 8081/tcp` gives just the PID.
- `netstat -tulpn` is the older tool. It is still what you get on hosts that do not have `ss`.
- No `-p` output? You need root to see other users' processes.
- Test a port without a client: `nc -zv 127.0.0.1 8081`, or Bash's `exec 3<>/dev/tcp/127.0.0.1/8081`.
