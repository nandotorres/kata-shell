sed -i.bak \
  -e 's/^port=80$/port=8080/' \
  -e 's/^#debug=/debug=/' \
  -e '/^legacy_/d' \
  app.conf
