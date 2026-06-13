#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

REPO="${GITHUB_REPO:-googlepro1/avtonomny-agent-book}"
ACCOUNT_ID="${CLOUDFLARE_ACCOUNT_ID:-f8750e2eca8b02dc184b196bd36a155d}"

echo "=== GitHub Actions secrets for Subscriber API ==="
echo "Repository: $REPO"
echo

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) is required." >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Run: gh auth login" >&2
  exit 1
fi

chmod +x ./scripts/refresh-cloudflare-oauth-token.sh

if [[ -n "${CLOUDFLARE_API_TOKEN:-}" ]]; then
  echo "Using provided CLOUDFLARE_API_TOKEN (long-lived API token)."
  gh secret set CLOUDFLARE_API_TOKEN --repo "$REPO" --body "$CLOUDFLARE_API_TOKEN"
  gh secret delete CLOUDFLARE_OAUTH_REFRESH_TOKEN --repo "$REPO" 2>/dev/null || true
else
  echo "Refreshing OAuth token from wrangler login session..."
  tokens_json="$(NO_PROXY='*' ./scripts/refresh-cloudflare-oauth-token.sh --json)"
  access_token="$(python3 - <<'PY' "$tokens_json"
import json, sys
print(json.loads(sys.argv[1])["access_token"])
PY
)"
  refresh_token="$(python3 - <<'PY' "$tokens_json"
import json, sys
print(json.loads(sys.argv[1])["refresh_token"])
PY
)"

  gh secret set CLOUDFLARE_OAUTH_REFRESH_TOKEN --repo "$REPO" --body "$refresh_token"
  gh secret set CLOUDFLARE_API_TOKEN --repo "$REPO" --body "$access_token"
  echo "Saved OAuth refresh token + fresh access token."
fi

gh secret set CLOUDFLARE_ACCOUNT_ID --repo "$REPO" --body "$ACCOUNT_ID"

echo
echo "Secrets saved:"
gh secret list --repo "$REPO"
echo
echo "Re-run deploy: gh workflow run deploy-subscriber-api.yml --repo $REPO"
