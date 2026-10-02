du -sh data/*/ | sort -h
dir=$(du -s data/*/ | sort -n | tail -n 1 | cut -f2)
file=$(find data -type f -printf '%k\t%p\n' | sort -n | tail -n 1 | cut -f2)
printf 'dir=%s\nfile=%s\n' "${dir%/}" "$file" > answer.txt
