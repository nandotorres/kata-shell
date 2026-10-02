compare_str "photos/ has the expected names" "$(ls -1 photos | LC_ALL=C sort)" <<'EOF'
Beach_Day_2026.jpg
IMG_0001.jpg
IMG_0002.jpg
My Notes.txt
Old Scan.jpeg
already_ok.jpg
EOF
compare_str "renamed files kept their content" "$(cat photos/IMG_0001.jpg photos/Beach_Day_2026.jpg 2>&1)" <<'EOF'
original name: IMG 0001.JPG
original name: Beach Day 2026.JPG
EOF
