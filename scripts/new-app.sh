#!/usr/bin/env bash
# Create a new hobby app from the agent factory template.
#   ./scripts/new-app.sh ../space-bunnies
set -euo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
target="${1:-}"
[[ -n "$target" ]] || { echo "Usage: ./scripts/new-app.sh <path-to-new-app>"; exit 1; }
[[ ! -e "$target" ]] || { echo "$target already exists"; exit 1; }

mkdir -p "$target"
cp -R "$here/template/." "$target/"
name="$(basename "$target")"
sed -i.bak "s/^# App name/# $name/" "$target/README.md" && rm -f "$target/README.md.bak"
cd "$target"
git init -q
git add -A
git commit -qm "chore: start $name from agent factory template"
echo "Created $target"
echo "Next: cd $target && claude, then type /brainstorm"
