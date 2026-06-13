#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
POCKETBASE="$ROOT_DIR/tools/pocketbase/pocketbase"

if [[ ! -x "$POCKETBASE" ]]; then
  echo "PocketBase is not installed. Run ./scripts/install-pocketbase.sh first." >&2
  exit 1
fi

exec "$POCKETBASE" serve \
  --dir="$ROOT_DIR/pocketbase/pb_data" \
  --migrationsDir="$ROOT_DIR/pocketbase/pb_migrations" \
  --http="127.0.0.1:8090"
