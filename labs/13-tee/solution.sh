./build 2>&1 | tee build.log /dev/stderr | grep -c WARN > warn-count.txt
