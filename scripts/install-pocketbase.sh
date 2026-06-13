#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS_DIR="$ROOT_DIR/tools/pocketbase"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

case "$(uname -s)" in
  Linux) os="linux" ;;
  Darwin) os="darwin" ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

case "$(uname -m)" in
  x86_64|amd64) arch="amd64" ;;
  aarch64|arm64) arch="arm64" ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

mkdir -p "$TOOLS_DIR"

release_json="$TMP_DIR/release.json"
python3 - "$release_json" <<'PY'
import json
import sys
import urllib.request

url = "https://api.github.com/repos/pocketbase/pocketbase/releases/latest"
with urllib.request.urlopen(url) as response:
    data = json.load(response)

with open(sys.argv[1], "w", encoding="utf-8") as file:
    json.dump(data, file)
PY

download_url="$(python3 - "$release_json" "$os" "$arch" <<'PY'
import json
import sys

release_path, os_name, arch = sys.argv[1:4]
with open(release_path, encoding="utf-8") as file:
    data = json.load(file)

needle = f"_{os_name}_{arch}.zip"
for asset in data["assets"]:
    if asset["name"].endswith(needle):
        print(asset["browser_download_url"])
        break
else:
    raise SystemExit(f"No PocketBase asset found for {os_name}/{arch}")
PY
)"

archive="$TMP_DIR/pocketbase.zip"
python3 - "$download_url" "$archive" <<'PY'
import sys
import urllib.request

urllib.request.urlretrieve(sys.argv[1], sys.argv[2])
PY

python3 - "$archive" "$TOOLS_DIR" <<'PY'
import sys
import zipfile

archive, target = sys.argv[1:3]
with zipfile.ZipFile(archive) as zip_file:
    zip_file.extract("pocketbase", target)
PY

chmod +x "$TOOLS_DIR/pocketbase"
"$TOOLS_DIR/pocketbase" --version
