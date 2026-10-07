ps -eo pid,%cpu,etime,args --sort=-%cpu | head -n 5
pid=$(ps -eo pid=,args= --sort=-%cpu | awk '/\.svc\// {print $1; exit}')
echo "$pid" > hog.pid
kill "$pid"            # SIGTERM: the process may trap it and clean up
