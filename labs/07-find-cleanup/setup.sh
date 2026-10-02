mkdir -p "cache/sub dir" cache/deep/er
mk() { printf 'x\n' > "$1"; touch -d "$2" "$1"; }
mk cache/a.tmp                    '10 days ago'
mk cache/b.tmp                    '2 days ago'
mk cache/new.tmp                  'now'
mk cache/notes.txt                '40 days ago'
mk "cache/sub dir/old file.tmp"   '30 days ago'
mk "cache/sub dir/keep.log"       '30 days ago'
mk cache/deep/er/x.tmp            '8 days ago'
mk cache/deep/er/y.TMP            '20 days ago'
mk cache/deep/er/z.tmp.bak        '20 days ago'
mk $'cache/weird\nname.tmp'       '9 days ago'
