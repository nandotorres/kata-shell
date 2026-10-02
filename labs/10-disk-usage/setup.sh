mkdir -p data/logs data/cache data/uploads data/db data/tmp
blob() { head -c "$2" /dev/zero > "$1"; }
for i in $(seq -w 1 12); do blob "data/uploads/photo-$i.jpg" 1M; done   # 12M total, small files
blob data/logs/app.log.1 6M                                            # biggest single file
blob data/logs/app.log 1M
blob data/db/part-1.dat 4M
blob data/db/part-2.dat 4M
blob data/cache/thumbs.bin 3M
truncate -s 1G data/tmp/sparse.img                                     # 1G apparent, ~0 on disk
