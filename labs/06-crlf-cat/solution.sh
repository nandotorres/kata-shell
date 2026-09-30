cat -A deploy.sh          # shows ^M$ at each line end: CRLF
sed -i 's/\r$//' deploy.sh
chmod +x deploy.sh
./deploy.sh && cat deployed.txt
