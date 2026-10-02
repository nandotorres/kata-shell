mkdir -p photos
for name in "IMG 0001.JPG" "IMG 0002.JPG" "Beach Day 2026.JPG" "already_ok.jpg" "Old Scan.jpeg" "My Notes.txt"; do
  printf 'original name: %s\n' "$name" > "photos/$name"
done
