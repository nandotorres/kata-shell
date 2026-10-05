./noisy > out.log 2> err.log
./noisy > all.log 2>&1; echo $? > status.txt
