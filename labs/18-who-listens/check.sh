compare "answer.txt has the 8081 PID and the public ports" answer.txt <<EOF
pid=$(cat "$KATA_RUN/18.api-gateway.pid")
public_ports=4444 8081
EOF
