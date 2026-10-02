cd photos
shopt -s nullglob
for f in *.JPG; do
  new=${f// /_}
  new=${new%.JPG}.jpg
  mv -n -- "$f" "$new"
done
