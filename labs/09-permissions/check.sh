compare_str "modes are exactly right" "$(find project -printf '%p %m\n' | LC_ALL=C sort)" <<'EOF'
project 755
project/bin 755
project/bin/run.sh 755
project/docs 755
project/docs/a.md 644
project/docs/b.md 644
project/public 755
project/public/index.html 644
project/secret.key 600
project/shared 1777
EOF
