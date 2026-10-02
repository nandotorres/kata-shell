mkdir -p project/bin project/docs project/public project/shared
printf 'KEY=hunter2\n' > project/secret.key
printf '#!/bin/sh\necho running\n' > project/bin/run.sh
printf '# A\n' > project/docs/a.md
printf '# B\n' > project/docs/b.md
printf '<h1>hi</h1>\n' > project/public/index.html
find project -type d -exec chmod 777 {} +
find project -type f -exec chmod 666 {} +
chmod 777 project/docs/a.md
chmod 600 project/public/index.html
