find project -type d -exec chmod 755 {} +
find project -type f -exec chmod 644 {} +
chmod 600  project/secret.key
chmod 755  project/bin/run.sh
chmod 1777 project/shared
