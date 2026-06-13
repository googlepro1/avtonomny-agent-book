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

if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
  cat <<'EOF'
CLOUDFLARE_API_TOKEN is not set.

Create a long-lived token (recommended):
  1. Open https://dash.cloudflare.com/profile/api-tokens
  2. Create Token → template "Edit Cloudflare Workers"
  3. Account Resources → include your account
  4. Copy the token value

Then run:
  CLOUDFLARE_API_TOKEN='your-token' ./scripts/setup-github-secrets.sh

Temporary fallback (expires with wrangler login session):
  npx wrangler login
  CLOUDFLARE_API_TOKEN="$(NO_PROXY='*' npx wrangler auth token --json | python3 -c "import json,sys; print(json.load(sys.stdin)['token'])")" ./scripts/setup-github-secrets.sh
EOF
  exit 1
fi

gh secret set CLOUDFLARE_API_TOKEN --repo "$REPO" --body "$CLOUDFLARE_API_TOKEN"
gh secret set CLOUDFLARE_ACCOUNT_ID --repo "$REPO" --body "$ACCOUNT_ID"

echo
echo "Secrets saved:"
gh secret list --repo "$REPO"
echo
echo "Re-run deploy: gh workflow run deploy-subscriber-api.yml --repo $REPO"
