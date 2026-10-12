cat > backup.sh <<'EOF'
#!/bin/bash
# backup.sh SRC DEST_DIR  — first draft
SRC=$1
DEST=$2
mkdir -p $DEST
tar -czf $DEST/$(basename $SRC)-$(date +%Y%m%d).tar.gz $SRC
echo "done!"
EOF
chmod +x backup.sh
mkdir -p "sample data/sub"
printf 'hello\n' > "sample data/a.txt"
printf 'world\n' > "sample data/sub/b.txt"
