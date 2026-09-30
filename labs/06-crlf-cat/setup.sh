printf '%s\r\n' \
  '#!/usr/bin/env bash' \
  'set -euo pipefail' \
  'echo "deployed version 1.4.2" > deployed.txt' > deploy.sh
chmod 644 deploy.sh
