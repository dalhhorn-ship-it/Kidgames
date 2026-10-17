#!/usr/bin/env bash
# Turn a copy of the factory repo (GitHub "Use this template") into an app.
# Moves template/ to the root and removes the factory only files.
#   ./scripts/make-app.sh
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
[[ -d template ]] || { echo "No template/ folder. This repo is already an app."; exit 0; }
origin="$(git remote get-url origin 2>/dev/null || true)"
if [[ "$(echo "$origin" | tr 'A-Z' 'a-z')" == *dalhhorn-ship-it/kidgames* && -z "${FACTORY_FORCE:-}" ]]; then
  echo "This is the factory repo itself. Not unpacking."; exit 1
fi

rm -rf .claude learnings README.md CLAUDE.md scripts/test-template.sh
tmp="$(mktemp -d)"
cp -R template/. "$tmp/"
rm -rf template scripts/make-app.sh
cp -R "$tmp/." .
rm -rf "$tmp"

name="$(basename "${origin%.git}")"; [[ -n "$name" ]] || name="$(basename "$root")"
sed -i.bak "s/^started:.*/started: $(date +%Y-%m-%d)/" .factory && rm -f .factory.bak
echo "App ready: $name. Next: say what you want to make."
