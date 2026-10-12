cat > backup.sh <<'EOF'
#!/usr/bin/env bash
# backup.sh SRC DEST_DIR — archive SRC into DEST_DIR/<name>-<YYYYMMDD>.tar.gz, print the archive path
set -euo pipefail

usage() { echo "usage: backup.sh SRC DEST_DIR" >&2; exit 2; }
die()   { echo "backup.sh: $*" >&2; exit 1; }

main() {
  (( $# == 2 )) || usage
  local src=$1 dest=$2
  [[ -d $src ]] || die "source is not a directory: $src"

  local name out
  name=$(basename -- "$src")
  out="$dest/$name-$(date +%Y%m%d).tar.gz"

  mkdir -p -- "$dest"
  tar -C "$(dirname -- "$src")" -czf "$out" -- "$name"
  printf '%s\n' "$out"
}

main "$@"
EOF
chmod +x backup.sh
shellcheck -S warning backup.sh && ./backup.sh "sample data" backups
