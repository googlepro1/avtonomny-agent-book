#!/usr/bin/env bash
# Публикация на GitHub Pages. Требует: gh auth login
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

GH="${GH:-/tmp/gh_2.63.2_linux_amd64/bin/gh}"
if ! command -v gh >/dev/null 2>&1; then
  if [[ -x "$GH" ]]; then
    export PATH="$(dirname "$GH"):$PATH"
  else
    echo "Установите GitHub CLI: https://cli.github.com/"
    exit 1
  fi
fi

gh auth status >/dev/null 2>&1 || {
  echo "Сначала: gh auth login"
  exit 1
}

REPO_NAME="${1:-avtonomny-agent-book}"
VIS="${2:-public}"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  git init -b main
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  gh repo create "$REPO_NAME" --"$VIS" --source=. --remote=origin --push --description "Лендинг книги «Автономный Агент» — написано Fable 5"
else
  git add -A
  git diff --staged --quiet || git -c user.name="Book" -c user.email="book@users.noreply.github.com" commit -m "Update book site and content"
  git push -u origin main
fi

OWNER="$(gh api user -q .login)"
gh api "repos/${OWNER}/${REPO_NAME}/pages" -X POST -f build_type=workflow 2>/dev/null || \
  gh api "repos/${OWNER}/${REPO_NAME}/pages" -X PUT -f build_type=workflow 2>/dev/null || true

echo ""
echo "Репозиторий: https://github.com/${OWNER}/${REPO_NAME}"
echo "Pages (через 1–2 мин): https://${OWNER}.github.io/${REPO_NAME}/"
echo "Settings → Pages → Source должен быть: GitHub Actions"
