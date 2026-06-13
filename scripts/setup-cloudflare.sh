#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "=== Cloudflare Worker + D1 setup ==="
echo

if [[ ! -f wrangler.toml ]]; then
  cp wrangler.toml.example wrangler.toml
  echo "Created wrangler.toml from wrangler.toml.example"
fi

if ! command -v npx >/dev/null 2>&1; then
  echo "Node.js/npx is required. Run: npm install" >&2
  exit 1
fi

echo "Steps:"
echo
echo "1. Login:"
echo "   npx wrangler login"
echo
echo "2. Create D1 (once, if not exists):"
echo "   npx wrangler d1 create subscribers"
echo "   Put database_id into wrangler.toml"
echo
echo "3. Apply schema:"
echo "   npx wrangler d1 migrations apply subscribers --remote"
echo
echo "4. Deploy Worker:"
echo "   npx wrangler deploy"
echo
echo "5. Update site/api-config.js with Worker URL, e.g.:"
echo "   https://avtonomny-agent-subscribers.mikxyotubes.workers.dev/api/subscribe"
echo
echo "6. Push to GitHub for Pages deploy:"
echo "   git push origin main"
echo
echo "Current prod (if already deployed):"
echo "  Site: https://googlepro1.github.io/avtonomny-agent-book/"
echo "  API:  https://avtonomny-agent-subscribers.mikxyotubes.workers.dev/api/subscribe"
echo
echo "Export emails:"
echo "  npx wrangler d1 execute subscribers --remote --command \"SELECT * FROM subscribers ORDER BY created_at DESC\""
