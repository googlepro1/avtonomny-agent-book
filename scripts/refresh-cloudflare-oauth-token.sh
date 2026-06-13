#!/usr/bin/env bash
set -euo pipefail

REFRESH_TOKEN="${CLOUDFLARE_OAUTH_REFRESH_TOKEN:-}"
CLIENT_ID="${CLOUDFLARE_OAUTH_CLIENT_ID:-54d11594-84e4-41aa-b438-e81b8fa78ee7}"
JSON_OUTPUT=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON_OUTPUT=true; shift ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$REFRESH_TOKEN" ]]; then
  CONFIG="${WRANGLER_CONFIG:-$HOME/.config/.wrangler/config/default.toml}"
  if [[ -f "$CONFIG" ]]; then
    REFRESH_TOKEN="$(python3 - "$CONFIG" <<'PY'
import sys
from pathlib import Path
text = Path(sys.argv[1]).read_text()
for line in text.splitlines():
    if line.startswith("refresh_token"):
        print(line.split("=", 1)[1].strip().strip('"'))
        break
PY
)"
  fi
fi

if [[ -z "$REFRESH_TOKEN" ]]; then
  echo "Set CLOUDFLARE_OAUTH_REFRESH_TOKEN or run npx wrangler login first." >&2
  exit 1
fi

response="$(curl -sS -X POST "https://dash.cloudflare.com/oauth2/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "grant_type=refresh_token" \
  --data-urlencode "refresh_token=${REFRESH_TOKEN}" \
  --data-urlencode "client_id=${CLIENT_ID}")"

python3 - <<'PY' "$response" "$JSON_OUTPUT"
import json, sys
data = json.loads(sys.argv[1])
json_output = sys.argv[2] == "true"
access = data.get("access_token") or ""
refresh = data.get("refresh_token") or ""
if not access:
    print("Cloudflare token refresh failed:", file=sys.stderr)
    print(json.dumps(data, indent=2), file=sys.stderr)
    raise SystemExit(1)
if json_output:
    print(json.dumps({"access_token": access, "refresh_token": refresh, "expires_in": data.get("expires_in")}))
else:
    print(access)
PY
