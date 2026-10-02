find cache -type f -iname '*.tmp' -mtime +7 -print    # dry run first
find cache -type f -iname '*.tmp' -mtime +7 -printf '.' -delete | wc -c > deleted-count.txt
